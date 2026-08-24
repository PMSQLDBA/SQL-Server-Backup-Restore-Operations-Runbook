/*
CHANGE-EXECUTION TEMPLATE - CREATES A DIFFERENTIAL BACKUP.
Requires a valid differential base.
*/
DECLARE @DatabaseName sysname=N'CHANGE_ME';
DECLARE @BackupFile nvarchar(4000)=N'CHANGE_ME_diff.bak';
DECLARE @Approved bit=0;
IF @Approved<>1 THROW 50000,'SAFETY STOP: review variables and set @Approved = 1.',1;

DECLARE @sql nvarchar(max)=N'BACKUP DATABASE '+QUOTENAME(@DatabaseName)+
N' TO DISK=N'''+REPLACE(@BackupFile,'''','''''')+N''' WITH DIFFERENTIAL, CHECKSUM, STATS=10;';
PRINT @sql;
EXEC sys.sp_executesql @sql;
