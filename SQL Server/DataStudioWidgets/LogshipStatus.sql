DECLARE @LowRPOWarning INT = 5
DECLARE @MediumRPOWarning INT = 20
DECLARE @HighRPOWarning INT = 40

;WITH LastRestores AS
(
SELECT
    [d].[name] [Database],
    bmf.physical_device_name [LastFileRestored],
    bs.backup_start_date LastFileRestoredCreatedTime,
    r.restore_date [DateRestored],        
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
    INNER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
    INNER JOIN msdb..backupset bs ON [r].[backup_set_id] = [bs].[backup_set_id]
    INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id] 
)
SELECT 
    [Database],
     DATEDIFF(MINUTE,LastFileRestoredCreatedTime,GETDATE()) MinutesBehind,
     DATEDIFF(MINUTE, [DateRestored],GETDATE()) MinutesSinceLastRestore
FROM [LastRestores]
WHERE [RowNum] = 1