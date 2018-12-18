CREATE EVENT SESSION MemoryUseageAbove10mb ON SERVER 
ADD EVENT sqlserver.query_memory_grant_usage --Ignores querys below 5mb 
	(
        ACTION(sqlserver.sql_text)
        WHERE ([granted_memory_kb] > 10000) --Above 10mb
    )
WITH 
	(MAX_MEMORY=1024 KB)
