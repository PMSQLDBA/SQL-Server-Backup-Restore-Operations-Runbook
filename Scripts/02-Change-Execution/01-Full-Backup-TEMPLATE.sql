/*
CHANGE-EXECUTION TEMPLATE - CREATES A BACKUP FILE.
Review and test before use.
*/
/*
Purpose: Create and verify a full SQL Server database backup.
Change-execution script: YES
Read-only: NO

Important:
  - Review all variables before execution.
  - Set @Approved = 1 only after review.
  - SQL Server service account must have write access to @BackupFile.
  - Backup is created WITH CHECKSUM.
  - RESTORE VERIFYONLY is executed after the backup completes.
  - VERIFYONLY validates backup readability but does not replace a real restore test.
*/

SET NOCOUNT ON;

DECLARE @DatabaseName sysname = N'Admindb';
DECLARE @BackupFile nvarchar(4000) = N'T:\Admindb_08Aug202612345.bak';

-- 0 = Safety stop
-- 1 = Approved to execute backup
DECLARE @Approved bit = 1;

-- 0 = Append to existing backup media
-- 1 = Initialize/overwrite existing backup media
DECLARE @OverwriteExistingFile bit = 0;


-- ============================================================
-- SAFETY VALIDATION
-- ============================================================

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

IF LOWER(RIGHT(@BackupFile, 4)) <> N'.bak'
BEGIN
    THROW 50004,
          'Backup file should use the .bak extension.',
          1;
END;


-- ============================================================
-- VARIABLES
-- ============================================================

DECLARE @BackupSQL nvarchar(max);
DECLARE @VerifySQL nvarchar(max);

DECLARE @BackupStartTime datetime2(0);
DECLARE @BackupEndTime datetime2(0);

DECLARE @VerifyStartTime datetime2(0);
DECLARE @VerifyEndTime datetime2(0);

DECLARE @BackupSucceeded bit = 0;
DECLARE @VerifySucceeded bit = 0;


-- ============================================================
-- BUILD BACKUP COMMAND
-- ============================================================

SET @BackupSQL =
    N'BACKUP DATABASE ' +
    QUOTENAME(@DatabaseName) +
    N'
TO DISK = N''' +
    REPLACE(@BackupFile, N'''', N'''''') +
    N'''
WITH
    CHECKSUM,
    STATS = 10' +

    CASE
        WHEN @OverwriteExistingFile = 1
            THEN N',
    INIT'
        ELSE N''
    END +

    N';';


-- ============================================================
-- DISPLAY BACKUP COMMAND
-- ============================================================

PRINT '============================================================';
PRINT 'BACKUP COMMAND';
PRINT '============================================================';
PRINT @BackupSQL;
PRINT '';


-- ============================================================
-- EXECUTE BACKUP
-- ============================================================

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
        'BACKUP DATABASE' AS CheckName,
        'FAIL' AS Status,
        @BackupStartTime AS StartTime,
        @BackupEndTime AS EndTime,
        DATEDIFF(SECOND, @BackupStartTime, @BackupEndTime)
            AS DurationSeconds,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS Details;

    THROW;

END CATCH;


-- ============================================================
-- BACKUP SUCCESS RESULT
-- ============================================================

IF @BackupSucceeded = 1
BEGIN

    SELECT
        @@SERVERNAME AS ServerName,
        @DatabaseName AS DatabaseName,
        @BackupFile AS BackupFile,
        'BACKUP DATABASE' AS CheckName,
        'PASS' AS Status,
        @BackupStartTime AS StartTime,
        @BackupEndTime AS EndTime,
        DATEDIFF(SECOND, @BackupStartTime, @BackupEndTime)
            AS DurationSeconds,

        CASE
            WHEN @OverwriteExistingFile = 1
                THEN 'OVERWRITE / INIT'
            ELSE
                'APPEND / NOINIT'
        END AS BackupFileMode,

        'Backup completed successfully with CHECKSUM.'
            AS Details;

END;


-- ============================================================
-- BUILD VERIFY COMMAND
-- ============================================================

SET @VerifySQL =
    N'RESTORE VERIFYONLY
FROM DISK = N''' +
    REPLACE(@BackupFile, N'''', N'''''') +
    N'''
WITH CHECKSUM;';


-- ============================================================
-- DISPLAY VERIFY COMMAND
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT 'BACKUP VERIFICATION';
PRINT '============================================================';
PRINT @VerifySQL;
PRINT '';


-- ============================================================
-- VERIFY BACKUP
-- ============================================================

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
        DATEDIFF(SECOND, @VerifyStartTime, @VerifyEndTime)
            AS DurationSeconds,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS Details;

    THROW;

END CATCH;


-- ============================================================
-- VERIFY SUCCESS RESULT
-- ============================================================

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
        DATEDIFF(SECOND, @VerifyStartTime, @VerifyEndTime)
            AS DurationSeconds,
        'Backup verification completed successfully.'
            AS Details;

END;


-- ============================================================
-- FINAL SUMMARY
-- ============================================================

SELECT
    @@SERVERNAME AS ServerName,
    @DatabaseName AS DatabaseName,
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
                'Backup and RESTORE VERIFYONLY completed successfully.'
        ELSE
                'Review backup or verification errors.'
    END AS Details;
