/*
HIGH-IMPACT CHANGE TEMPLATE - RESTORES A DATABASE.
Designed for restore to a NEW database name. Inspect FILELISTONLY first.
Replace logical file names and target paths.
*/
DECLARE @BackupFile nvarchar(4000)=N'CHANGE_ME.bak';
DECLARE @TargetDatabase sysname=N'CHANGE_ME_RESTORE';
DECLARE @LogicalDataName sysname=N'CHANGE_ME_DATA';
DECLARE @LogicalLogName sysname=N'CHANGE_ME_LOG';
DECLARE @DataFile nvarchar(4000)=N'CHANGE_ME.mdf';
DECLARE @LogFile nvarchar(4000)=N'CHANGE_ME.ldf';
DECLARE @Approved bit=0;

IF @Approved<>1 THROW 50000,'SAFETY STOP: validate target, file list, paths, capacity, and approvals.',1;
IF DB_ID(@TargetDatabase) IS NOT NULL THROW 50000,'Target database already exists. This template refuses to overwrite it.',1;

DECLARE @sql nvarchar(max)=
N'RESTORE DATABASE '+QUOTENAME(@TargetDatabase)+
N' FROM DISK=N'''+REPLACE(@BackupFile,'''','''''')+N''' WITH '+
N'MOVE N'''+REPLACE(@LogicalDataName,'''','''''')+N''' TO N'''+REPLACE(@DataFile,'''','''''')+N''', '+
N'MOVE N'''+REPLACE(@LogicalLogName,'''','''''')+N''' TO N'''+REPLACE(@LogFile,'''','''''')+N''', '+
N'RECOVERY, CHECKSUM, STATS=10;';
PRINT @sql;
EXEC sys.sp_executesql @sql;
