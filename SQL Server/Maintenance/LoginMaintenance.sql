--Logins with a non existant default DB
SELECT
    logins.name AS LoginName,
    logins.default_database_name DefaultDatabase
FROM
    sys.server_principals logins
    LEFT JOIN sys.databases databases ON 
		databases.name = logins.default_database_name
WHERE 
	databases.name IS NULL
    AND logins.default_database_name IS NOT NULL