/*Variables*****************/
DECLARE @DatabaseName NVARCHAR(20) = N'DatabaseName'
DECLARE @PrimaryServer NVARCHAR(200) = N'My-Primary-Server\My-Primary-Instance'
DECLARE @PrimaryTransactionLocation NVARCHAR(200) = N'\\Server\LogFileLocation\MyDb\'
DECLARE @LocalTransactionLocation NVARCHAR(200) = N'D:\Log Shipping\MyDb\'
DECLARE @SychScheduleMinutes INT = 5

/*Constants*****************/
DECLARE @LS_Secondary__CopyJobId UNIQUEIDENTIFIER
DECLARE @LS_Secondary__RestoreJobId UNIQUEIDENTIFIER
DECLARE @LS_Secondary__SecondaryId  UNIQUEIDENTIFIER

/*Program********************/
DECLARE @CopyJobName NVARCHAR(200) = 'LSCopy_' + @PrimaryServer + '_' + @DatabaseName
DECLARE @RestoreJobName NVARCHAR(200) = 'LSRestore_' + @PrimaryServer + '_' + @DatabaseName
DECLARE @LS_Add_RetCode INT

--Configure server as secondary log shipping server
EXEC @LS_Add_RetCode = master.dbo.sp_add_log_shipping_secondary_primary 
    @primary_server = @PrimaryServer
    ,@primary_database = @DatabaseName 
    ,@backup_source_directory = @PrimaryTransactionLocation
    ,@backup_destination_directory = @LocalTransactionLocation 
    ,@copy_job_name = @CopyJobName
    ,@restore_job_name = @RestoreJobName
    ,@file_retention_period = 7200 
    ,@overwrite = 1 
    ,@copy_job_id = @LS_Secondary__CopyJobId OUTPUT 
    ,@restore_job_id = @LS_Secondary__RestoreJobId OUTPUT 
    ,@secondary_id = @LS_Secondary__SecondaryId OUTPUT 
	
IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) 
	BEGIN 
	DECLARE @LS_SecondaryCopyJobScheduleUID As UNIQUEIDENTIFIER 
	DECLARE @LS_SecondaryCopyJobScheduleID  AS INT 
	EXEC msdb.dbo.sp_add_schedule 
		@schedule_name =N'DefaultCopyJobSchedule' 
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
		,@schedule_uid = @LS_SecondaryCopyJobScheduleUID OUTPUT 
		,@schedule_id = @LS_SecondaryCopyJobScheduleID OUTPUT 
	EXEC msdb.dbo.sp_attach_schedule 
		@job_id = @LS_Secondary__CopyJobId 
		,@schedule_id = @LS_SecondaryCopyJobScheduleID  
	DECLARE @LS_SecondaryRestoreJobScheduleUID  As UNIQUEIDENTIFIER 
	DECLARE @LS_SecondaryRestoreJobScheduleID   AS INT 
	EXEC msdb.dbo.sp_add_schedule 
		@schedule_name =N'DefaultRestoreJobSchedule' 
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
		,@schedule_uid = @LS_SecondaryRestoreJobScheduleUID OUTPUT 
		,@schedule_id = @LS_SecondaryRestoreJobScheduleID OUTPUT 

	EXEC msdb.dbo.sp_attach_schedule 
		@job_id = @LS_Secondary__RestoreJobId 
		,@schedule_id = @LS_SecondaryRestoreJobScheduleID  
	END 

DECLARE @LS_Add_RetCode2 As INT 
IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) 
	BEGIN 
	EXEC @LS_Add_RetCode2 = master.dbo.sp_add_log_shipping_secondary_database 
		@secondary_database = @DatabaseName
		,@primary_server = @PrimaryServer
		,@primary_database = @DatabaseName
		,@restore_delay = 0 
		,@restore_mode = 0
		,@disconnect_users = 1 
		,@restore_threshold = 180   
		,@threshold_alert_enabled = 1 
		,@history_retention_period = 7200
		,@overwrite = 1
	END 

IF (@@error = 0 AND @LS_Add_RetCode = 0) 
	BEGIN 
	EXEC msdb.dbo.sp_update_job @job_id = @LS_Secondary__CopyJobId, @enabled = 1 
	EXEC msdb.dbo.sp_update_job @job_id = @LS_Secondary__RestoreJobId, @enabled = 1 
	END 

GO



