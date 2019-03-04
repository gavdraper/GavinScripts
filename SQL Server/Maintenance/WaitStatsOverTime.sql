/* HH:MM:SS */
DECLARE @DelayString NVARCHAR(8) = '00:00:05'
SELECT * INTO #WaitTypesToIgnore
FROM(
    VALUES
        ('SLEEP_TASK'),('DIRTY_PAGE_POLL'),('HADR_FILESTREAM_IOMGR_IOCOMPLETION'),('LOGMGR_QUEUE'),
        ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP'),('ONDEMAND_TASK_QUEUE'),('FT_IFTSHC_MUTEX'),('REQUEST_FOR_DEADLOCK_SEARCH'),
        ('LAZYWRITER_SLEEP'),('SOS_WORK_DISPATCHER'),('CHECKPOINT_QUEUE'),('XE_TIMER_EVENT'),('FT_IFTS_SCHEDULER_IDLE_WAIT'),
        ('BROKER_TO_FLUSH'),('BROKER_TASK_STOP'),('BROKER_EVENTHANDLER'),('WAITFOR'),('DBMIRROR_DBM_MUTEX'),
        ('DBMIRROR_EVENTS_QUEUE'),('DBMIRRORING_CMD'),('DISPATCHER_QUEUE_SEMAPHORE'),('QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'),
        ('QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'),('SP_SERVER_DIAGNOSTICS_SLEEP'),('XE_DISPATCHER_WAIT'),('REQUEST_FOR_DEADLOCK_SEARCH'),
        ('SQLTRACE_BUFFER_FLUSH'),('XE_DISPATCHER_WAIT'),('BROKER_RECEIVE_WAITFOR'),('CLR_AUTO_EVENT'),('DIRTY_PAGE_POLL'),
        ('HADR_FILESTREAM_IOMGR_IOCOMPLETION'),('CLR_MANUAL_EVENT')
) x(WaitType)

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