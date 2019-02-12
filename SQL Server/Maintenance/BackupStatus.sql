-- USE [msdb]
-- GO
-- CREATE NONCLUSTERED INDEX ndx_backupset_type_db_finish
-- ON [dbo].[backupset] ([type],[database_name],[backup_finish_date])
-- INCLUDE ([backup_size])
-- GO

SELECT
    DB_NAME(dbs.database_id) AS [Database],
    dbs.recovery_model_desc AS [RecoveryModel],
    ISNULL(CAST(DATEDIFF(HOUR,LastFull.backup_finish_date,GETDATE()) AS VARCHAR(20)) +' Hours','NO FULL BACKUP!') [FullBackupAge],
    ISNULL(CAST(LastFull.backup_size AS VARCHAR(20)) + 'MB','0MB') [FullBackupSize],
    ISNULL(CAST(DATEDIFF(HOUR,DifferentialSummary.backup_finish_date,GETDATE()) AS VARCHAR(20)) + ' Hours','Never') [DifferentialBackupAge],
    ISNULL(CAST(DifferentialSummary.BackupSizeSinceFull AS VARCHAR(20)) + 'MB','0MB') [TotalDifferentialSizeSinceFull],
    ISNULL(CAST(DATEDIFF(SECOND,LogSummary.backup_finish_date,GETDATE()) AS VARCHAR(20)) + ' Seconds','Never') [LogBackupAge],
    ISNULL(CAST(LogSummary.BackupSizeSinceDiffOrFull AS VARCHAR(20)) + 'MB','0MB') [TotalLogSizeSinceDiffOrFull],
    ISNULL(CAST(ISNULL(DifferentialSummary.BackupSizeSinceFull,0) +
        ISNULL(LogSummary.BackupSizeSinceDiffOrFull,0) +
        LastFull.backup_size  AS VARCHAR(20)) + 'MB','0MB') [TotalSizeToRestore]
FROM 
    sys.databases dbs

    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_finish_date, 
            CAST((backupset.backup_size/1024)/1024 AS INT) backup_size, 
            bmf.physical_device_name
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.[Type] = 'D' 
        ORDER BY backup_finish_date DESC
    ) LastFull

    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_finish_date, 
            backupset.backup_size, 
            bmf.physical_device_name,
            DiffAggregations.BackupSizeSinceFull
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
            OUTER APPLY(
                SELECT
                    CAST((SUM(aggr.backup_size)/1024)/1024 AS INT) BackupSizeSinceFull
                FROM
                    msdb.dbo.backupset aggr
                WHERE   
                    aggr.database_name = DB_NAME(dbs.database_id) AND
                    aggr.backup_finish_date > LastFull.backup_finish_date AND
                    aggr.[Type] = 'I'  

            ) DiffAggregations            
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.[Type] = 'I'  AND
            backupset.backup_finish_date > LastFull.backup_finish_date
        ORDER BY backup_finish_date DESC
    ) DifferentialSummary    

    OUTER APPLY(
        SELECT TOP 1 
            backupset.backup_finish_date, 
            backupset.backup_size, 
            bmf.physical_device_name,
            LogAggregations.BackupSizeSinceDiffOrFull
        FROM 
            msdb.dbo.backupset 
            LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = backupset.media_set_id
            OUTER APPLY(
                SELECT
                    CAST((SUM(aggr.backup_size)/1024)/1024 AS INT) BackupSizeSinceDiffOrFull
                FROM
                    msdb.dbo.backupset aggr
                WHERE   
                    aggr.database_name = DB_NAME(dbs.database_id) AND
                    aggr.backup_finish_date > ISNULL(DifferentialSummary.backup_finish_date ,LastFull.backup_finish_date) AND
                    aggr.[type] = 'L'
            ) LogAggregations
        WHERE 
            backupset.database_name = DB_NAME(dbs.database_id) AND 
            backupset.[Type] = 'L'  
        ORDER BY backup_finish_date DESC
    ) LogSummary        

WHERE   
    dbs.source_database_id IS NULL
ORDER BY    
    [Database]