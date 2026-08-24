/*
CHANGE-EXECUTION TEMPLATE - CREATES A BACKUP FILE.
Review and test before use.
*/
SET NOCOUNT ON;
DECLARE @DatabaseName sysname = N'CHANGE_ME';
DECLARE @BackupFile nvarchar(4000) = N'CHANGE_ME.bak';
DECLARE @Approved bit = 0; -- set to 1 only after review

IF @Approved <> 1 THROW 50000, 'SAFETY STOP: review variables and set @Approved = 1.', 1;
IF DB_ID(@DatabaseName) IS NULL THROW 50000, 'Database not found.', 1;

DECLARE @sql nvarchar(max) =
N'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) +
N' TO DISK = N''' + REPLACE(@BackupFile,'''','''''') +
N''' WITH CHECKSUM, STATS = 10;';
PRINT @sql;
EXEC sys.sp_executesql @sql;
