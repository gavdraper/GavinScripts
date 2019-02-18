/* HH:MM:SS */
DECLARE @DelayString NVARCHAR(8) = '00:00:05'
SELECT * INTO #WaitTypesToIgnore
FROM(
    SELECT 'SLEEP_TASK' AS WaitType
    UNION ALL SELECT 'DIRTY_PAGE_POLL'
    UNION ALL SELECT 'HADR_FILESTREAM_IOMGR_IOCOMPLETION'
    UNION ALL SELECT 'LOGMGR_QUEUE'   
    UNION ALL SELECT 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'
    UNION ALL SELECT 'ONDEMAND_TASK_QUEUE'
    UNION ALL SELECT 'FT_IFTSHC_MUTEX'
    UNION ALL SELECT 'REQUEST_FOR_DEADLOCK_SEARCH'
    UNION ALL SELECT 'LAZYWRITER_SLEEP'
    UNION ALL SELECT 'SOS_WORK_DISPATCHER'
    UNION ALL SELECT 'CHECKPOINT_QUEUE'
    UNION ALL SELECT 'XE_TIMER_EVENT'
    UNION ALL SELECT 'FT_IFTS_SCHEDULER_IDLE_WAIT'
    UNION ALL SELECT 'BROKER_TO_FLUSH'
    UNION ALL SELECT 'BROKER_TASK_STOP'
    UNION ALL SELECT 'BROKER_EVENTHANDLER'
    UNION ALL SELECT 'WAITFOR'
    UNION ALL SELECT 'DBMIRROR_DBM_MUTEX'
    UNION ALL SELECT 'DBMIRROR_EVENTS_QUEUE'
    UNION ALL SELECT 'DBMIRRORING_CMD'
    UNION ALL SELECT 'DISPATCHER_QUEUE_SEMAPHORE'
    UNION ALL SELECT 'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'
    UNION ALL SELECT 'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'
    UNION ALL SELECT 'SP_SERVER_DIAGNOSTICS_SLEEP'
    UNION ALL SELECT 'XE_DISPATCHER_WAIT'
    UNION ALL SELECT 'REQUEST_FOR_DEADLOCK_SEARCH'
    UNION ALL SELECT 'SQLTRACE_BUFFER_FLUSH'
    UNION ALL SELECT 'XE_DISPATCHER_WAIT'
    UNION ALL SELECT 'BROKER_RECEIVE_WAITFOR'
    UNION ALL SELECT 'CLR_AUTO_EVENT'
    UNION ALL SELECT 'DIRTY_PAGE_POLL'
    UNION ALL SELECT 'HADR_FILESTREAM_IOMGR_IOCOMPLETION'
    UNION ALL SELECT 'CLR_MANUAL_EVENT'
) x

SELECT dm_os_wait_stats.* 
INTO #StartStats
FROM 
    sys.dm_os_wait_stats
    LEFT JOIN #WaitTypesToIgnore ON dm_os_wait_stats.wait_type = #WaitTypesToIgnore.WaitType
WHERE 
    #WaitTypesToIgnore.WaitType IS NULL

WAITFOR DELAY @DelayString

SELECT 
    [now].wait_type,
    [now].waiting_tasks_count - ISNULL([before].waiting_tasks_count,0) waiting_tasks_count,
    [now].[wait_time_ms] - ISNULL([before].wait_time_ms,0) wait_time_ms,
    [now].[max_wait_time_ms] - ISNULL([before].max_wait_time_ms,0) max_wait_time_ms,
    [now].[signal_wait_time_ms] - ISNULL([before].signal_wait_time_ms,0) signal_wait_time_ms
FROM 
    sys.dm_os_wait_stats [now]
    LEFT JOIN #StartStats [before] ON [before].wait_type = [now].Wait_type
    LEFT JOIN #WaitTypesToIgnore ON #WaitTypesToIgnore.WaitType = [now].Wait_type
WHERE
    #WaitTypesToIgnore.WaitType IS NULL AND
    (
        ([now].waiting_tasks_count - ISNULL([before].waiting_tasks_count,0)) > 0
        OR ([now].[wait_time_ms] - ISNULL([before].wait_time_ms,0)) > 0
        OR ([now].[max_wait_time_ms] - ISNULL([before].max_wait_time_ms,0)) > 0
        OR ([now].[signal_wait_time_ms] - ISNULL([before].signal_wait_time_ms,0)) > 0 
    )
ORDER BY  [now].[wait_time_ms] - ISNULL([before].wait_time_ms,0) DESC