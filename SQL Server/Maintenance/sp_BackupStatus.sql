/*
You may also want to create this index, I had some issues querying the 
below tables without it.
USE [msdb]
GO
CREATE NONCLUSTERED INDEX ndx_backupset_type_db_start
ON [dbo].[backupset] ([type],[database_name],[backup_start_date])
INCLUDE ([backup_size])
GO
*/
USE master
GO
DROP PROCEDURE IF EXISTS sp_BackupStatus
GO
CREATE PROCEDURE sp_BackupStatus
AS
SELECT
    DB_NAME(dbs.database_id) AS [Database],
    dbs.recovery_model_desc AS [RecoveryModel],
    ISNULL(CAST(DATEDIFF(MINUTE,LastFull.backup_start_date,GETDATE()) AS VARCHAR(20)) +' Minutes','NO FULL BACKUP!') [FullAge],
    ISNULL(CAST(LastFull.backup_size AS VARCHAR(20)) + 'MB','0MB') [FullSize],
    
    ISNULL(CAST(DATEDIFF(MINUTE,DifferentialSummary.backup_start_date,GETDATE()) AS VARCHAR(20)) + ' Minutes','Never') [LastDiffAge],
    ISNULL(CAST(DifferentialSummary.BackupSizeSinceFull AS VARCHAR(20)) + 'MB','0MB') [DiffRestoreSize],
    DifferentialSummary.FileCount [DiffFileCount],
    
    ISNULL(CAST(DATEDIFF(MINUTE,LogSummary.backup_start_date,GETDATE()) AS VARCHAR(20)) + ' Minutes','Never') [LastLogAge],
    ISNULL(CAST(LogSummary.BackupSizeSinceDiffOrFull AS VARCHAR(20)) + 'MB','0MB') [LogRestoreSize],
    LogSummary.FileCount [LogFileCount],

    ISNULL(CAST(ISNULL(DifferentialSummary.BackupSizeSinceFull,0) +
        ISNULL(LogSummary.BackupSizeSinceDiffOrFull,0) +
        LastFull.backup_size  AS VARCHAR(20)) + 'MB','0MB') [TotalSizeToRestore]
FROM 
    sys.databases dbs
    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_start_date, 
            CAST((backupset.backup_size/1024)/1024 AS INT) backup_size, 
            bmf.physical_device_name
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.[Type] = 'D' 
        ORDER BY backup_start_date DESC
    ) LastFull
    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_start_date, 
            backupset.backup_size, 
            bmf.physical_device_name,
            DiffAggregations.BackupSizeSinceFull,
            DiffAggregations.FileCount
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
            OUTER APPLY(
                SELECT
                    COUNT(*) AS FileCount,
                    CAST((SUM(aggr.backup_size)/1024)/1024 AS INT) BackupSizeSinceFull
                FROM
                    msdb.dbo.backupset aggr
                WHERE   
                    aggr.database_name = DB_NAME(dbs.database_id) AND
                    aggr.backup_start_date >= LastFull.backup_start_date AND
                    aggr.[Type] = 'I'  

            ) DiffAggregations            
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.[Type] = 'I'  AND
            backupset.backup_start_date >= LastFull.backup_start_date
        ORDER BY backup_start_date DESC
    ) DifferentialSummary    
    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_start_date, 
            backupset.backup_size, 
            bmf.physical_device_name,
            LogAggregations.BackupSizeSinceDiffOrFull,
            LogAggregations.FileCount
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
            OUTER APPLY(
                SELECT
                    COUNT(*) FileCount,
                    CAST((SUM(aggr.backup_size)/1024)/1024 AS INT) BackupSizeSinceDiffOrFull
                FROM
                    msdb.dbo.backupset aggr
                WHERE   
                    aggr.database_name = DB_NAME(dbs.database_id) AND
                    aggr.backup_start_date >= ISNULL(DifferentialSummary.backup_start_date ,LastFull.backup_start_date) AND
                    aggr.[type] = 'L'
            ) LogAggregations
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.backup_start_date >= ISNULL(DifferentialSummary.backup_start_date ,LastFull.backup_start_date) AND
            backupset.[Type] = 'L'  
        ORDER BY backup_start_date DESC
    ) LogSummary        

WHERE   
    DB_NAME(dbs.database_id) NOT IN ('master','model','msdb','tempdb')
ORDER BY    
    [Database]