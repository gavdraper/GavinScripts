SELECT 
    o.name [Table],
    i.name [Index],
    (COUNT(*) *8)/1024 [SizeMB]
FROM
    sys.allocation_units au 
    INNER JOIN sys.dm_os_buffer_descriptors bd ON au.allocation_unit_id = bd.allocation_unit_id
    INNER JOIN sys.partitions p ON  
        /* allocation_unit types : 
            0=Dropped, 
            1 = In Row, 
            2=LOB, 
            3=Row-Overflow data*/
        (au.[type] IN (1,3) AND au.container_id = p.hobt_id) 
        OR (au.[type] = 2 AND au.container_id = p.partition_id)
    INNER JOIN sys.objects o ON p.object_id = o.object_id
    LEFT JOIN sys.indexes i ON i.object_id = o.object_id AND p.index_id = i.index_id
 WHERE 
    o.type NOT IN ('S','IT') 
GROUP BY
    i.name,
    o.name

    