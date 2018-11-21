DECLARE @Path NVARCHAR(200) = 'd:\'

DROP TABLE IF EXISTS #AllDataFiles
DECLARE @cmd NVARCHAR(300) = 'cmd /c "cd /d ' + @path + ' && dir /b /s | sort | findstr /c:".mdf" /c:".ldf""'
CREATE TABLE #AllDataFiles (mdfFileName VARCHAR(max))
INSERT INTO #AllDataFiles 
	EXEC xp_cmdshell @cmd
SELECT mdfFileName FROM #AllDataFiles WHERE mdfFileName IS NOT NULL
EXCEPT
SELECT physical_name FROM sys.master_files