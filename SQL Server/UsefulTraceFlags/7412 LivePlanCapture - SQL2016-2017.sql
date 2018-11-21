/*
    Auto live capture profile page 172 traceflag 7412 on by default in 2019
*/

DBCC TRACEON(7412,-1)

/*
    Got to activity monitor in SQL Server
    Expand Active Expensive Queries
    Right click one 
    View Live Execution Plan


DROP TABLE #RunningQueries

SELECT 
	p.sql_handle, 
	p.plan_handle,
	p.session_id,
	p.request_id 
INTO 
	#RunningQueries 
FROM 
	sys.dm_exec_query_profiles p
WHERE
	DB_NAME(p.database_id) <> 'master'
GROUP BY 
	p.sql_handle, 
	p.plan_handle, 
	p.session_id,
	p.request_id

SELECT 
	[sql].text [SQL],
	[plan].query_plan,
	'
		SELECT 
			session_id,
			request_id,
			p.physical_operator_name,
			p.estimate_row_count,
			p.actual_read_row_count,
			DB_NAME(database_id) DB,
			OBJECT_NAME(object_id,database_id) Obj,
			[object_id] ObjId,
			OBJECT_NAME(index_id,database_id) Ix,
			i.name IxId,
			scan_count,
			logical_read_count,
			write_page_count,
			p.estimated_read_row_count,
			p.actual_read_row_count
		FROM sys.dm_exec_query_profiles p 
			LEFT JOIN DB_NAME(database_id) + .sys.indexes AS i ON 
				i.object_id = p.object_id
				AND i.index_id = p.index_id

		WHERE 
			session_id = ' + CAST(session_id AS NVARCHAR(200)) + '
			AND request_id = ' + CAST(request_id AS NVARCHAR(200)) + '
	' AS [live_stats]
FROM 
	#RunningQueries p
	CROSS APPLY(SELECT * FROM sys.dm_exec_sql_text(sql_handle)) [sql]
	OUTER APPLY(SELECT * FROM sys.dm_exec_query_plan (plan_handle)) [plan]



*/


