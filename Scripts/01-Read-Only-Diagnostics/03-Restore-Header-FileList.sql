/*
Purpose: Generate inspection commands for a backup file before restore.
Read-only: YES - RESTORE HEADERONLY/FILELISTONLY do not restore the database.
Set @BackupFile to a trusted path accessible by SQL Server.
*/
DECLARE @BackupFile nvarchar(4000) = N'CHANGE_ME.bak';
IF @BackupFile = N'CHANGE_ME.bak'
    THROW 50000, 'Set @BackupFile before running.', 1;

DECLARE @sql nvarchar(max);
SET @sql = N'RESTORE HEADERONLY FROM DISK = N''' + REPLACE(@BackupFile,'''','''''') + N''';';
EXEC sys.sp_executesql @sql;

SET @sql = N'RESTORE FILELISTONLY FROM DISK = N''' + REPLACE(@BackupFile,'''','''''') + N''';';
EXEC sys.sp_executesql @sql;
