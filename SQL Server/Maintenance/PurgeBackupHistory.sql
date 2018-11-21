DECLARE @StartDate DATETIME = '20170430'
DECLARE @EndDate DATETIME = '20170530'
WHILE @StartDate < @EndDate
	BEGIN
	DECLARE @DeletionTime DATETIME = GETDATE()
	EXEC msdb.dbo.sp_delete_backuphistory @oldest_date =  @StartDate
	CHECKPOINT
	DECLARE @msg NVARCHAR(100)
	SELECT @msg= 'Archived ' + CAST(@StartDate AS NVARCHAR(12)) + ' In ' + CAST(DATEDIFF(MINUTE,@DeletionTime,GETDATE()) AS NVARCHAR(10)) + ' Minutes'
	RAISERROR (@msg  , 0, 1) WITH NOWAIT
	SELECT @StartDate = DATEADD(day,1,@StartDate)
	END
	