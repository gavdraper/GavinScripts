DECLARE @DatabaseName NVARCHAR(200) = 'MyDatabase'
DECLARE @Path NVARCHAR(200) = 'd:\MyLogs\'

DECLARE @cmd NVARCHAR(300) = 'cmd /c "cd /d ' + @path +' && dir /b /s | sort | findstr /c:".trn""'
/*If you need to restore from a UNC path you'll need to mount and unmount the path..
    SELECT @cmd = 'cmd /c "subst b: ' + @path + ' && cd /d b:\ && dir /b /s | sort | findstr /c:".trn" && subst b: /d"'
*/

CREATE TABLE #AllLogFiles (Logfile VARCHAR(1000))
INSERT INTO #AllLogFiles 
EXEC xp_cmdshell @cmd

SELECT 
    'RESTORE LOG ' + @DatabaseName + ' ' + @Path + '\' + REPLACE(LogFile,'B:\','')
FROM #AllLogFiles
WHERE LogFile IS NOT NULL
ORDER BY LogFile

