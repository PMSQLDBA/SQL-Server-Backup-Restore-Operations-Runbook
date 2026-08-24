/*
Purpose: Basic post-restore verification.
Read-only: YES
Set @DatabaseName.
DBCC CHECKDB is intentionally NOT executed automatically because it can be resource intensive.
*/
SET NOCOUNT ON;
DECLARE @DatabaseName sysname = N'CHANGE_ME';
IF DB_ID(@DatabaseName) IS NULL THROW 50000, 'Database not found.', 1;

SELECT name, state_desc, user_access_desc, recovery_model_desc,
       compatibility_level, is_read_only
FROM sys.databases
WHERE name = @DatabaseName;

SELECT TOP (50)
       destination_database_name,
       restore_date,
       restore_type,
       replace,
       recovery,
       user_name
FROM msdb.dbo.restorehistory
WHERE destination_database_name = @DatabaseName
ORDER BY restore_date DESC;

SELECT N'Review application connectivity, SQL Agent dependencies, users/logins, permissions, database owner, jobs, linked integrations, and run DBCC CHECKDB during an approved window.' AS RecommendedValidation;
