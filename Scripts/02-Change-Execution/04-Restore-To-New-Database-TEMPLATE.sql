/*
HIGH-IMPACT CHANGE TEMPLATE - RESTORES A DATABASE.
Designed for restore to a NEW database name. Inspect FILELISTONLY first.
Replace logical file names and target paths.
*/
Here’s the safest way to use that restore template step by step.

1. Check the backup file first.

```sql
RESTORE HEADERONLY
FROM DISK = N'T:\DBAScripts_22Aug2026.bak';
```

In the output, confirm the correct backup set and note its `Position`.

2. Inspect the logical file names.

```sql
RESTORE FILELISTONLY
FROM DISK = N'T:\DBAScripts_22Aug2026.bak'
WITH FILE = 1;
```

Look at the `LogicalName` and `Type` columns. For a normal database you may see something like:

```text
LogicalName     Type
--------------  ----
AdminDB         D
AdminDB_log     L
```

3. Choose a new target database name.

For example:

```sql
DECLARE @TargetDatabase sysname =
    N'Admin_Test_Restore';
```

Make sure this database does not already exist.

4. Set the logical names exactly as returned by `FILELISTONLY`.

```sql
DECLARE @LogicalDataName sysname = N'AdminDB';
DECLARE @LogicalLogName sysname  = N'AdminDB_log';
```

Do not invent these names.

5. Set the new physical file locations.

```sql
DECLARE @DataFile nvarchar(4000) =
    N'E:\LocalLabs2026\SQLDefault\SQLData\AdminDB_Test_Restore_DATA.mdf';

DECLARE @LogFile nvarchar(4000) =
    N'E:\LocalLabs2026\SQLDefault\SQLLog\AdminDB_Test_Restore_LOG.ldf';
```

Confirm those folders exist and SQL Server can write to them.

6. Set the backup file and backup-set position.

```sql
DECLARE @BackupFile nvarchar(4000) =
    N'T:\DBAScripts_22Aug2026.bak';

DECLARE @BackupSetPosition int = 1;
```

If `HEADERONLY` showed the backup you want at position `2`, use:

```sql
DECLARE @BackupSetPosition int = 2;
```

7. Keep the safety switch at `0` while reviewing.

```sql
DECLARE @Approved bit = 0;
```

At this point, review all variables carefully.

8. If everything is correct, change only this:

```sql
DECLARE @Approved bit = 1;
```

9. Run the full restore script.

The script will build a command similar to:

```sql
RESTORE DATABASE [Admin_Test_Restore]
FROM DISK = N'T:\DBAScripts_22Aug2026.bak'
WITH
    FILE = 1,
    MOVE N'AdminDB'
        TO N'E:\LocalLabs2026\SQLDefault\SQLData\AdminDB_Test_Restore_DATA.mdf',
    MOVE N'AdminDB_log'
        TO N'E:\LocalLabs2026\SQLDefault\SQLLog\AdminDB_Test_Restore_LOG.ldf',
    RECOVERY,
    CHECKSUM,
    STATS = 10;
```

10. Review the output.

If successful, you should get a `PASS` result and the final query should show:

```text
DatabaseName         DatabaseState    Status
-------------------  ---------------  ------
Admin_Test_Restore   ONLINE           PASS
```

One important rule: if `RESTORE FILELISTONLY` returns more than one data file, such as `.mdf` plus `.ndf` files, you must add a `MOVE` clause for every file before running the restore.

Also, because this template uses `RECOVERY`, it brings the database online immediately. If you plan to restore a differential backup or transaction log backups afterward, the full restore must use `NORECOVERY` instead.

Final Code:

/*
HIGH-IMPACT CHANGE TEMPLATE - RESTORES A DATABASE.

Designed for restore to a NEW database name.
Inspect RESTORE HEADERONLY and RESTORE FILELISTONLY first.

Read-only: NO
High-impact: YES
*/

SET NOCOUNT ON;

DECLARE @BackupFile nvarchar(4000) = N'CHANGE_ME.bak';
DECLARE @BackupSetPosition int = 1;

DECLARE @TargetDatabase sysname = N'CHANGE_ME_RESTORE';

DECLARE @LogicalDataName sysname = N'CHANGE_ME_DATA';
DECLARE @LogicalLogName sysname = N'CHANGE_ME_LOG';

DECLARE @DataFile nvarchar(4000) = N'CHANGE_ME.mdf';
DECLARE @LogFile nvarchar(4000) = N'CHANGE_ME.ldf';

-- 0 = Safety stop
-- 1 = Approved to execute restore
DECLARE @Approved bit = 0;


/* ============================================================
   SAFETY VALIDATION
   ============================================================ */

IF @Approved <> 1
BEGIN
    THROW 50000,
          'SAFETY STOP: validate target, backup set, file list, paths, capacity, and approvals.',
          1;
END;

IF @BackupFile IS NULL
   OR LTRIM(RTRIM(@BackupFile)) = N''
   OR @BackupFile = N'CHANGE_ME.bak'
BEGIN
    THROW 50001,
          'Set @BackupFile before running.',
          1;
END;

IF @BackupSetPosition IS NULL
   OR @BackupSetPosition < 1
BEGIN
    THROW 50002,
          '@BackupSetPosition must be 1 or greater.',
          1;
END;

IF @TargetDatabase IS NULL
   OR LTRIM(RTRIM(@TargetDatabase)) = N''
   OR @TargetDatabase = N'CHANGE_ME_RESTORE'
BEGIN
    THROW 50003,
          'Set @TargetDatabase before running.',
          1;
END;

IF DB_ID(@TargetDatabase) IS NOT NULL
BEGIN
    THROW 50004,
          'Target database already exists. This template refuses to overwrite it.',
          1;
END;

IF @LogicalDataName IS NULL
   OR LTRIM(RTRIM(@LogicalDataName)) = N''
   OR @LogicalDataName = N'CHANGE_ME_DATA'
BEGIN
    THROW 50005,
          'Set @LogicalDataName using RESTORE FILELISTONLY output.',
          1;
END;

IF @LogicalLogName IS NULL
   OR LTRIM(RTRIM(@LogicalLogName)) = N''
   OR @LogicalLogName = N'CHANGE_ME_LOG'
BEGIN
    THROW 50006,
          'Set @LogicalLogName using RESTORE FILELISTONLY output.',
          1;
END;

IF @DataFile IS NULL
   OR LTRIM(RTRIM(@DataFile)) = N''
   OR @DataFile = N'CHANGE_ME.mdf'
BEGIN
    THROW 50007,
          'Set @DataFile before running.',
          1;
END;

IF @LogFile IS NULL
   OR LTRIM(RTRIM(@LogFile)) = N''
   OR @LogFile = N'CHANGE_ME.ldf'
BEGIN
    THROW 50008,
          'Set @LogFile before running.',
          1;
END;


/* ============================================================
   BUILD RESTORE COMMAND
   ============================================================ */

DECLARE @sql nvarchar(max);

SET @sql =
    N'RESTORE DATABASE ' +
    QUOTENAME(@TargetDatabase) +
    N'
FROM DISK = N''' +
    REPLACE(@BackupFile, N'''', N'''''') +
    N'''
WITH
    FILE = ' +
    CONVERT(nvarchar(20), @BackupSetPosition) +
    N',
    MOVE N''' +
    REPLACE(@LogicalDataName, N'''', N'''''') +
    N''' TO N''' +
    REPLACE(@DataFile, N'''', N'''''') +
    N''',
    MOVE N''' +
    REPLACE(@LogicalLogName, N'''', N'''''') +
    N''' TO N''' +
    REPLACE(@LogFile, N'''', N'''''') +
    N''',
    RECOVERY,
    CHECKSUM,
    STATS = 10;';


/* ============================================================
   DISPLAY COMMAND
   ============================================================ */

PRINT '============================================================';
PRINT 'RESTORE COMMAND';
PRINT '============================================================';
PRINT @sql;


/* ============================================================
   EXECUTE RESTORE
   ============================================================ */

BEGIN TRY

    EXEC sys.sp_executesql @sql;

    SELECT
        @@SERVERNAME AS ServerName,
        @TargetDatabase AS DatabaseName,
        @BackupFile AS BackupFile,
        @BackupSetPosition AS BackupSetPosition,
        'PASS' AS Status,
        'Database restore completed successfully.' AS Details;

END TRY
BEGIN CATCH

    SELECT
        @@SERVERNAME AS ServerName,
        @TargetDatabase AS DatabaseName,
        @BackupFile AS BackupFile,
        'FAIL' AS Status,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS Details;

    THROW;

END CATCH;


/* ============================================================
   FINAL DATABASE STATUS
   ============================================================ */

SELECT
    d.name AS DatabaseName,
    d.state_desc AS DatabaseState,
    d.recovery_model_desc AS RecoveryModel,
    d.user_access_desc AS UserAccess,

    CASE
        WHEN d.state_desc = 'ONLINE'
            THEN 'PASS'
        ELSE 'WARNING'
    END AS Status

FROM sys.databases AS d
WHERE d.name = @TargetDatabase;
