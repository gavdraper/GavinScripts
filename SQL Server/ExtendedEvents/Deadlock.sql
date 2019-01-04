CREATE EVENT SESSION DeadLocks ON SERVER 
ADD EVENT sqlserver.lock_deadlock
(
    ACTION(sqlserver.sql_text)
),
ADD EVENT sqlserver.lock_deadlock_chain
(
    ACTION(sqlserver.sql_text)
),
ADD EVENT sqlserver.xml_deadlock_report
WITH (MAX_MEMORY=4096 KB)