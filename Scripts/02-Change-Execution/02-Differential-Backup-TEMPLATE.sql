/*
File: 02-Differential-Backup-TEMPLATE.sql

Purpose:
  Create and verify a differential SQL Server database backup.

Change-execution script: YES
Read-only: NO

Important:
  - Review all variables before execution.
  - Set @Approved = 1 only after review.
  - A valid non-copy-only full database backup must exist as the differential base.
  - SQL Server service account must have write access to @BackupFile.
  - Differential backup files use the .diff extension.
  - Backup is created WITH DIFFERENTIAL and CHECKSUM.
  - RESTORE VERIFYONLY is executed after the backup completes.
  - VERIFYONLY validates backup readability but does not replace a real restore test.
*/

SET NOCOUNT ON;

DECLARE @DatabaseName sysname = N'Admindb';
DECLARE @BackupFile nvarchar(4000) =
    N'T:\Admindb_DIFF_20260823_210000.diff';

-- 0 = Safety stop
-- 1 = Approved to execute backup
DECLARE @Approved bit = 1;

-- 0 = Append to existing backup media
-- 1 = Initialize/overwrite existing backup media
DECLARE @OverwriteExistingFile bit = 0;


/* ============================================================
   SAFETY VALIDATION
   ============================================================ */

IF @Approved <> 1
BEGIN
    THROW 50000,
          'SAFETY STOP: review variables and set @Approved = 1.',
          1;
END;

IF @DatabaseName IS NULL
   OR LTRIM(RTRIM(@DatabaseName)) = N''
BEGIN
    THROW 50001,
          'Database name is required.',
          1;
END;

IF DB_ID(@DatabaseName) IS NULL
BEGIN
    THROW 50002,
          'The specified database does not exist on this SQL Server instance.',
          1;
END;

IF @BackupFile IS NULL
   OR LTRIM(RTRIM(@BackupFile)) = N''
BEGIN
    THROW 50003,
          'Backup file path is required.',
          1;
END;

IF LOWER(RIGHT(@BackupFile, 5)) <> N'.diff'
BEGIN
    THROW 50004,
          'Differential backup file must use the .diff extension.',
          1;
END;


/* ============================================================
   DIFFERENTIAL BASE CHECK
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.backupset AS bs
    WHERE bs.database_name = @DatabaseName
      AND bs.type = 'D'
      AND bs.is_copy_only = 0
)
BEGIN
    THROW 50005,
          'No non-copy-only full database backup was found in msdb. A differential backup requires a valid full backup base.',
          1;
END;


/* ============================================================
   VARIABLES
   ============================================================ */

DECLARE @BackupSQL nvarchar(max);
DECLARE @VerifySQL nvarchar(max);

DECLARE @BackupStartTime datetime2(0);
DECLARE @BackupEndTime datetime2(0);

DECLARE @VerifyStartTime datetime2(0);
DECLARE @VerifyEndTime datetime2(0);

DECLARE @BackupSucceeded bit = 0;
DECLARE @VerifySucceeded bit = 0;


/* ============================================================
   BUILD DIFFERENTIAL BACKUP COMMAND
   ============================================================ */

SET @BackupSQL =
    N'BACKUP DATABASE ' +
    QUOTENAME(@DatabaseName) +
    N'
TO DISK = N''' +
    REPLACE(@BackupFile, N'''', N'''''') +
    N'''
WITH
    DIFFERENTIAL,
    CHECKSUM,
    STATS = 10' +

    CASE
        WHEN @OverwriteExistingFile = 1
            THEN N',
    INIT'
        ELSE N''
    END +

    N';';


/* ============================================================
   DISPLAY BACKUP COMMAND
   ============================================================ */

PRINT '============================================================';
PRINT 'DIFFERENTIAL BACKUP COMMAND';
PRINT '============================================================';
PRINT @BackupSQL;
PRINT '';


/* ============================================================
   EXECUTE DIFFERENTIAL BACKUP
   ============================================================ */

BEGIN TRY

    SET @BackupStartTime = SYSDATETIME();

    EXEC sys.sp_executesql @BackupSQL;

    SET @BackupEndTime = SYSDATETIME();
    SET @BackupSucceeded = 1;

END TRY

BEGIN CATCH

    SET @BackupEndTime = SYSDATETIME();

    SELECT
        @@SERVERNAME AS ServerName,
        @DatabaseName AS DatabaseName,
        @BackupFile AS BackupFile,
        'DIFFERENTIAL BACKUP' AS CheckName,
        'FAIL' AS Status,
        @BackupStartTime AS StartTime,
        @BackupEndTime AS EndTime,
        DATEDIFF(
            SECOND,
            @BackupStartTime,
            @BackupEndTime
        ) AS DurationSeconds,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS Details;

    THROW;

END CATCH;


/* ============================================================
   BACKUP SUCCESS RESULT
   ============================================================ */

IF @BackupSucceeded = 1
BEGIN

    SELECT
        @@SERVERNAME AS ServerName,
        @DatabaseName AS DatabaseName,
        @BackupFile AS BackupFile,
        'DIFFERENTIAL BACKUP' AS CheckName,
        'PASS' AS Status,
        @BackupStartTime AS StartTime,
        @BackupEndTime AS EndTime,
        DATEDIFF(
            SECOND,
            @BackupStartTime,
            @BackupEndTime
        ) AS DurationSeconds,

        CASE
            WHEN @OverwriteExistingFile = 1
                THEN 'OVERWRITE / INIT'
            ELSE 'APPEND / NOINIT'
        END AS BackupFileMode,

        'Differential backup completed successfully with CHECKSUM.'
            AS Details;

END;


/* ============================================================
   BUILD VERIFY COMMAND
   ============================================================ */

SET @VerifySQL =
    N'RESTORE VERIFYONLY
FROM DISK = N''' +
    REPLACE(@BackupFile, N'''', N'''''') +
    N'''
WITH CHECKSUM;';


/* ============================================================
   DISPLAY VERIFY COMMAND
   ============================================================ */

PRINT '';
PRINT '============================================================';
PRINT 'DIFFERENTIAL BACKUP VERIFICATION';
PRINT '============================================================';
PRINT @VerifySQL;
PRINT '';


/* ============================================================
   VERIFY BACKUP
   ============================================================ */

BEGIN TRY

    SET @VerifyStartTime = SYSDATETIME();

    EXEC sys.sp_executesql @VerifySQL;

    SET @VerifyEndTime = SYSDATETIME();
    SET @VerifySucceeded = 1;

END TRY

BEGIN CATCH

    SET @VerifyEndTime = SYSDATETIME();

    SELECT
        @@SERVERNAME AS ServerName,
        @DatabaseName AS DatabaseName,
        @BackupFile AS BackupFile,
        'RESTORE VERIFYONLY' AS CheckName,
        'FAIL' AS Status,
        @VerifyStartTime AS StartTime,
        @VerifyEndTime AS EndTime,
        DATEDIFF(
            SECOND,
            @VerifyStartTime,
            @VerifyEndTime
        ) AS DurationSeconds,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS Details;

    THROW;

END CATCH;


/* ============================================================
   VERIFY SUCCESS RESULT
   ============================================================ */

IF @VerifySucceeded = 1
BEGIN

    SELECT
        @@SERVERNAME AS ServerName,
        @DatabaseName AS DatabaseName,
        @BackupFile AS BackupFile,
        'RESTORE VERIFYONLY' AS CheckName,
        'PASS' AS Status,
        @VerifyStartTime AS StartTime,
        @VerifyEndTime AS EndTime,
        DATEDIFF(
            SECOND,
            @VerifyStartTime,
            @VerifyEndTime
        ) AS DurationSeconds,
        'Differential backup verification completed successfully.'
            AS Details;

END;


/* ============================================================
   FINAL SUMMARY
   ============================================================ */

SELECT
    @@SERVERNAME AS ServerName,
    @DatabaseName AS DatabaseName,
    'DIFFERENTIAL' AS BackupType,
    @BackupFile AS BackupFile,

    CASE
        WHEN @BackupSucceeded = 1
            THEN 'PASS'
        ELSE 'FAIL'
    END AS BackupStatus,

    CASE
        WHEN @VerifySucceeded = 1
            THEN 'PASS'
        ELSE 'FAIL'
    END AS VerificationStatus,

    CASE
        WHEN @BackupSucceeded = 1
         AND @VerifySucceeded = 1
            THEN 'PASS'
        ELSE 'FAIL'
    END AS OverallStatus,

    @BackupEndTime AS BackupCompletedAt,
    @VerifyEndTime AS VerificationCompletedAt,

    CASE
        WHEN @BackupSucceeded = 1
         AND @VerifySucceeded = 1
            THEN
                'Differential backup and RESTORE VERIFYONLY completed successfully.'
        ELSE
                'Review backup or verification errors.'
    END AS Details;
