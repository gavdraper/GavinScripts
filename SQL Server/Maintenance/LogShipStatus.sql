DECLARE @LowRPOWarning INT = 5
DECLARE @MediumRPOWarning INT = 10
DECLARE @HighRPOWarning INT = 15

;WITH LastRestores AS
(
SELECT
    [d].[name] [Database],
    bmf.physical_device_name [LastFileRestored],
    RealDateTime.FinalDateTime [LastFileRestoredCreatedTime],
    r.restore_date [DateRestored],        
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
    INNER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
    INNER JOIN msdb..backupset bs ON [r].[backup_set_id] = [bs].[backup_set_id]
    INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id] 
    CROSS APPLY(SELECT SUBSTRING([physical_device_name],LEN([physical_device_name])-17,8) [date])  StringDate
    CROSS APPLY(SELECT SUBSTRING([physical_device_name],LEN([physical_device_name])-9,6) [time])  StringTime
    CROSS APPLY(SELECT 
            SUBSTRING(StringTime.Time,1,2) + ':' + 
            SUBSTRING(StringTime.Time,3,2) + ':' + 
            SUBSTRING(StringTime.Time,5,2) 
        [time])  CorrectedTime
    CROSS APPLY(SELECT StringDate.Date + ' ' + CorrectedTime.Time AS FinalDateTime)  RealDateTime
)
SELECT 
     CASE WHEN DATEDIFF(MINUTE,LastFileRestoredCreatedTime,GETDATE()) > @HighRPOWarning THEN 'RPO High Warning!'
        WHEN DATEDIFF(MINUTE,LastFileRestoredCreatedTime,GETDATE()) > @MediumRPOWarning THEN 'RPO Medium Warning!'
        WHEN DATEDIFF(MINUTE,LastFileRestoredCreatedTime,GETDATE()) > @LowRPOWarning THEN 'RPO Low Warning!'
        ELSE 'RPO Good'
     END [Status],
    [Database],
    [LastFileRestored],
    [LastFileRestoredCreatedTime],
    [DateRestored]
FROM [LastRestores]
WHERE [RowNum] = 1