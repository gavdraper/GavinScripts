SELECT	
	q.query_id,
	t.query_sql_text,
	q.query_parameterization_type_desc,
	MAX(q.last_execution_time) LastExecution,
	COUNT(DISTINCT p.plan_id) PlanCount,
	AVG(rs.count_executions)count_executions,
	AVG(rs.avg_duration)avg_duration,
	AVG(rs.last_duration)last_duration,
	AVG(rs.stdev_duration)stdev_duration,
	AVG(rs.avg_logical_io_reads)avg_logical_io_reads,
	AVG(rs.avg_logical_io_writes)avg_logical_io_writes,
	AVG(rs.avg_cpu_time)avg_cpu_time,
	AVG(rs.avg_query_max_used_memory)avg_query_max_used_memory,
	AVG(rs.avg_rowcount)avg_rowcount,
	AVG(rs.avg_tempdb_space_used)avg_tempdb_space_used,
	AVG(ws.avg_query_wait_time_ms)avg_query_wait_time_ms
FROM
	sys.query_store_query q
	LEFT JOIN sys.query_store_plan p ON p.query_id = q.query_id
	LEFT JOIN sys.query_store_query_text t ON t.query_text_id = q.query_text_id
	LEFT JOIN sys.query_store_runtime_stats rs ON rs.plan_id = p.plan_id
	LEFT JOIN sys.query_store_wait_stats ws ON ws.plan_id = p.plan_id
GROUP BY
	q.query_id,
	t.query_sql_text,
	q.query_parameterization_type_desc
ORDER BY (AVG(rs.avg_duration)*AVG(rs.count_executions)) DESC

