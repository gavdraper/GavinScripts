CREATE EVENT SESSION MemoryUseageAbove5Mb ON SERVER 
ADD EVENT sqlserver.query_memory_grant_usage
	(ACTION(sqlserver.sql_text))
WITH 
	(MAX_MEMORY=1024 KB)
