CREATE EVENT SESSION [RpcAndBatchCompletedForUserX] ON SERVER 
ADD EVENT sqlserver.rpc_completed
(
    ACTION
	(
		sqlserver.database_id,
		sqlserver.database_name,
		sqlserver.nt_username,
		sqlserver.server_principal_name,
		sqlserver.session_id
	)
    WHERE 
	(
		[sqlserver].[equal_i_sql_unicode_string]([sqlserver].[server_principal_name],N'domain\user') AND 
		[sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name],N'master') AND 
		[sqlserver].[is_system]<>(1)
	)
),
ADD EVENT sqlserver.sp_statement_completed
(
    ACTION
	(
		sqlserver.database_id,
		sqlserver.database_name,
		sqlserver.nt_username,
		sqlserver.server_principal_name,
		sqlserver.session_id
	)
    WHERE 
	(
		[sqlserver].[equal_i_sql_unicode_string]([sqlserver].[server_principal_name],N'domain\user') AND 
		[sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name],N'master') AND 
		[sqlserver].[is_system]<>(1)
	)
),
ADD EVENT sqlserver.sql_batch_completed
(
    ACTION
	(
		sqlserver.database_id,
		sqlserver.database_name,
		sqlserver.nt_username,
		sqlserver.server_principal_name,
		sqlserver.session_id
	)
    WHERE 
	(
		[sqlserver].[equal_i_sql_unicode_string]([sqlserver].[server_principal_name],N'domain\user') AND 
		[sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name],N'master') AND 
		[sqlserver].[is_system]<>(1)
	)
)
WITH (MAX_MEMORY=4096 KB)
GO


