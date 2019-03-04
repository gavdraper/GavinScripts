SELECT 
    o.name [ObjectName],
    i.name [IndexName],
    au.[type_Desc] [AllocationType],
    (au.total_pages*8)/1024 SizeMb
FROM 
    sys.allocation_units au
    INNER JOIN sys.partitions p ON  
        (au.[type] = 2 AND au.container_id = p.partition_id) OR
        (au.[type] IN (1,3) AND au.container_id = p.hobt_id)
    INNER JOIN sys.objects o ON p.object_id = o.object_id
    INNER JOIN sys.indexes i ON i.index_id = p.index_id AND i.object_id = o.object_id
WHERE
    o.[type] NOT IN ('S','IT')
ORDER BY o.name