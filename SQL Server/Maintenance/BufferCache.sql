--Get total size of buffer cache
SELECT (COUNT(*)*8)/1024 TotalSizeMb FROM sys.dm_os_buffer_descriptors

--Get usage breakdown
SELECT 
    d.name [Database],
    o.name [Table],
    i.name [Index],
    COUNT(*) AS [Pages],
    (COUNT(*) *8)/1024 [SizeMB] ,
    o.[type]
FROM
    sys.dm_os_buffer_descriptors bd
    INNER JOIN sys.databases d ON d.database_id = bd.database_id
    INNER JOIN sys.allocation_units au ON au.allocation_unit_id = bd.allocation_unit_id
    INNER JOIN sys.partitions p ON  
        /* allocation_unit types : 0=Dropped, 1 = In Row, 2=LOB, 3=Row-Overflow data*/
        (au.[type] IN (1,3) AND au.container_id = p.hobt_id) 
        OR (au.[type] = 2 AND au.container_id = p.partition_id)
    INNER JOIN sys.objects o ON p.object_id = o.object_id
    LEFT JOIN sys.indexes i ON i.object_id = o.object_id AND p.index_id = i.index_id
 WHERE 
    o.type <> 'S' --System base table
    AND d.name NOT IN ('master','model','msdb')
GROUP BY
    d.name,
    i.name,
    o.name,    
    au.type_desc,
    o.type


    