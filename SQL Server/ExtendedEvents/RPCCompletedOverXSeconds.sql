CREATE EVENT SESSION [RpcAndBatchCompletedOverXSeconds] ON SERVER 
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
		[package0].[not_equal_boolean]([sqlserver].[is_system],(1)) AND 
		[duration]>(10000000)
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
		[package0].[not_equal_boolean]([sqlserver].[is_system],(1)) AND 
		[duration]>(10000000)
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
		[package0].[not_equal_boolean]([sqlserver].[is_system],(1)) AND 
		[duration]>(10000000)
	)
)
WITH (MAX_MEMORY=4096 KB)
GO


