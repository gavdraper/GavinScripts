CREATE EVENT SESSION MemoryUseageAbove5Mb2 ON SERVER 
ADD EVENT sqlserver.query_memory_grant_usage
	(
        ACTION(sqlserver.sql_text)
        WHERE ([granted_memory_kb] > 10000)
    )
WITH 
	(MAX_MEMORY=1024 KB)
