/*
HIGH-IMPACT TEMPLATE - TAIL-LOG BACKUP.
Tail-log decisions are incident-specific. This can affect recovery workflow.
Do not use NO_TRUNCATE or NORECOVERY options casually.
*/
DECLARE @DatabaseName sysname=N'CHANGE_ME';
DECLARE @BackupFile nvarchar(4000)=N'CHANGE_ME_tail.trn';
DECLARE @Approved bit=0;

IF @Approved<>1 THROW 50000,'SAFETY STOP: incident owner/DBA must approve tail-log strategy.',1;
IF (SELECT recovery_model_desc FROM sys.databases WHERE name=@DatabaseName)='SIMPLE'
    THROW 50000,'Tail-log backup is generally not part of SIMPLE recovery workflows.',1;

-- Default template does NOT use NORECOVERY.
DECLARE @sql nvarchar(max)=N'BACKUP LOG '+QUOTENAME(@DatabaseName)+
N' TO DISK=N'''+REPLACE(@BackupFile,'''','''''')+N''' WITH CHECKSUM, STATS=10;';
PRINT @sql;
EXEC sys.sp_executesql @sql;
