-- Running
-- Suspended : Waiting on something
-- Runnable : In Queue waiting for time
-- Pending waiting on a worker thread to start it
-- Background : Background thread things like deadlock monitor
-- Sleeping SPID kept open but there is no work

SELECT 
    r.session_id,
    r.total_elapsed_time/1000 AS ElapsedTimeSeconds,
    s.host_name,
    s.login_name,
    s.open_transaction_count,
    r.start_time,
    r.status,
    r.command,
    [sql].[text],
    DB_NAME(r.database_id) DB,
    r.blocking_session_id,
    r.language,
    r.logical_reads,
    r.writes,
    r.cpu_time,
    p.usecounts AS PlanUseCount,
    r.wait_time,
    r.wait_type
    --,    pl.query_plan AS [Plan]
FROM   
    sys.dm_exec_requests r --Status info
    INNER JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id --Session (User info)
    INNER JOIN sys.dm_exec_cached_plans p ON p.plan_handle = r.plan_handle
    --CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS pl
    CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) AS [sql]
WHERE   
    r.[status] IN ('Suspended','Runnable','Running','Pending')
    AND  s.login_name <> 'waverton\magnasqlservice'    
ORDER BY r.total_elapsed_time DESC    