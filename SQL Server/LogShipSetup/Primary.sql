/*BEFORE YOU RUN MAKE SURE PRIMARY DATABASE IS IN FULL RECOVARY
SELECT name, databasepropertyex (name,'Recovery')
FROM master..sysdatabases
*/
DECLARE @Database NVARCHAR(100) = 'DBName'
DECLARE @BackupLocation NVARCHAR(300) = '\\MyServer\MyDbLogBackups\'
DECLARE @SecondaryServer NVARCHAR (50) = 'my-secondary-server\my-secondary-instance'
DECLARE @SychScheduleMinutes INT = 5
DECLARE @RetentionMinutes INT = 4320

SET @BackupLocation = @BackupLocation + @Database

DECLARE @LS_BackupJobId AS UNIQUEIDENTIFIER 
DECLARE @LS_PrimaryId   AS UNIQUEIDENTIFIER 
DECLARE @SP_Add_RetCode As INT 
DECLARE @BackupJobName NVARCHAR(100) = 'LSBackup_' + @Database
DECLARE @ScheduleName NVARCHAR(100) = 'LSBackupSchedule_'  + @Database

EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database 
        @database = @Database 
        ,@backup_directory = @BackupLocation 
        ,@backup_share = @BackupLocation 
        ,@backup_job_name = @BackupJobName
        ,@backup_retention_period = @RetentionMinutes
        ,@backup_threshold = 60 
        ,@threshold_alert_enabled = 1
        ,@history_retention_period = @RetentionMinutes 
        ,@backup_job_id = @LS_BackupJobId OUTPUT 
        ,@primary_id = @LS_PrimaryId OUTPUT 
        ,@overwrite = 1               

IF (@@ERROR = 0 AND @SP_Add_RetCode = 0) 
	BEGIN 
	DECLARE @LS_BackUpScheduleUID   As UNIQUEIDENTIFIER 
	DECLARE @LS_BackUpScheduleID    AS INT 

		EXEC msdb.dbo.sp_add_schedule 
			 @schedule_name =@ScheduleName
			,@enabled = 1 
			,@freq_type = 4 
			,@freq_interval = 1 
			,@freq_subday_type = 4 
			,@freq_subday_interval = @SychScheduleMinutes 
			,@freq_recurrence_factor = 0 
			,@active_start_date = 20090505 
			,@active_end_date = 99991231 
			,@active_start_time = 0 
			,@active_end_time = 235900 
			,@schedule_uid = @LS_BackUpScheduleUID OUTPUT 
			,@schedule_id = @LS_BackUpScheduleID OUTPUT 


	EXEC msdb.dbo.sp_attach_schedule 
        @job_id = @LS_BackupJobId 
        ,@schedule_id = @LS_BackUpScheduleID  

	EXEC msdb.dbo.sp_update_job 
        @job_id = @LS_BackupJobId 
        ,@enabled = 1 
	END 

EXEC master.dbo.sp_add_log_shipping_alert_job 

EXEC master.dbo.sp_add_log_shipping_primary_secondary 
    @primary_database = @Database
    ,@secondary_server = @SecondaryServer
    ,@secondary_database = @Database
    ,@overwrite = 1 


