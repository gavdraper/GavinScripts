/*
    Auto live capture profile page 172 traceflag 7412 on by default in 2019
*/

--DBCC TRACEON(7412,-1)

/*
    Got to activity monitor in SQL Server
    Expand Active Expensive Queries
    Right click one 
    View Live Execution Plan
*/

SET  TRANSACTION ISOLATION  LEVEL READ UNCOMMITTED

SELECT       
	   p.node_id NodeId,
       p.session_id SessionId,
	   p.request_id RequestId,
	   [sql].[text] [SQL],
	   p.physical_operator_name [PlanOperator], 
       obj.name AS  [Object],
       ix.name AS  [Index],	   
	   SUM(p.estimate_row_count) [EstimatedRows],
	   SUM(p.row_count) [ActualRows],
	   CAST(CAST(SUM(p.row_count) * 100 / SUM(p.estimate_row_count) AS DECIMAL(5,2)) AS VARCHAR(6)) + ' %' Progress,
	   wait.waitinfo
	   ,'SELECT query_plan FROM sys.dm_exec_query_plan (' + CONVERT(VARCHAR(MAX),plan_handle,1) + ')' GetPlan
FROM 
	sys.dm_exec_query_profiles p
    LEFT JOIN sys.objects obj ON p.object_id = obj.object_id
    LEFT JOIN sys.indexes ix ON p.index_id = ix.index_id AND p.object_id = ix.object_id
	CROSS APPLY(SELECT node_id FROM sys.dm_exec_query_profiles thisDb WHERE thisDb.session_id = p.session_id AND thisDb.request_id = p.request_id AND thisDb.database_id = DB_ID()) a
	CROSS APPLY(SELECT * FROM sys.dm_exec_sql_text(sql_handle)) [sql]
	OUTER APPLY(
       SELECT
		STUFF(
			(
				SELECT
					',' + ws.wait_type + ' ' + QUOTENAME(CAST(SUM(COALESCE(ws.wait_duration_ms, 0)) AS VARCHAR(20)) + ' ms')
				FROM 
					sys.dm_exec_requests AS r
					INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
					INNER JOIN sys.dm_os_waiting_tasks AS ws ON ws.session_id = s.session_id
				WHERE 
					s.session_id = p.session_id
				GROUP BY 
					ws.wait_type
				FOR XML PATH (''), TYPE
			).value('.', 'varchar(max)') , 1, 1, ''
         )
) AS wait(waitinfo)
WHERE	
	p.session_id <> @@spid
GROUP BY p.request_id, p.node_id, p.session_id, p.physical_operator_name, obj.name, ix.name,database_id,[sql].[text], wait.waitinfo,plan_handle
ORDER BY p.session_id, p.request_id







