SELECT  
	DB_NAME([Snapshot].Source_Database_Id) AS [SourceDatabase], 
	[Snapshot].Name AS [Snapshot],
	CAST((([SnapshotFileStats].Size_On_Disk_Bytes/1024)/1024)/1024 AS VARCHAR(10)) + 'GB' AS [Size]
FROM 
    sys.databases [Snapshot]
	INNER JOIN sys.master_files [SnapshotFile] ON [SnapshotFile].database_id = [Snapshot].database_id
	CROSS APPLY sys.dm_io_virtual_file_stats([Snapshot].database_id, [SnapshotFile].file_id) [SnapshotFileStats]
WHERE	
	[Snapshot].source_database_id IS NOT NULL
ORDER BY [Snapshot].[create_date] DESC