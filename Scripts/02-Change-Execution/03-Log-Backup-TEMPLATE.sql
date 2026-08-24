/*
CHANGE-EXECUTION TEMPLATE - CREATES A TRANSACTION LOG BACKUP.
Not applicable to SIMPLE recovery model.
*/
DECLARE @DatabaseName sysname=N'CHANGE_ME';
DECLARE @BackupFile nvarchar(4000)=N'CHANGE_ME.trn';
DECLARE @Approved bit=0;
IF @Approved<>1 THROW 50000,'SAFETY STOP: review variables and set @Approved = 1.',1;
IF (SELECT recovery_model_desc FROM sys.databases WHERE name=@DatabaseName) = 'SIMPLE'
    THROW 50000,'Log backups are not supported for SIMPLE recovery model.',1;

DECLARE @sql nvarchar(max)=N'BACKUP LOG '+QUOTENAME(@DatabaseName)+
N' TO DISK=N'''+REPLACE(@BackupFile,'''','''''')+N''' WITH CHECKSUM, STATS=10;';
PRINT @sql;
EXEC sys.sp_executesql @sql;
