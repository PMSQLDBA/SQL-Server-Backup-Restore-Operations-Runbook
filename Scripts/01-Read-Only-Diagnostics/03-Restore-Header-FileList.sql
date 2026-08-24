/*
Purpose: Inspect a SQL Server backup file before planning a restore.
Read-only: YES

Checks performed:
  1. RESTORE HEADERONLY   - Shows backup sets stored in the backup media.
  2. RESTORE FILELISTONLY - Shows logical and physical database files.
  3. RESTORE VERIFYONLY   - Verifies that SQL Server can read the selected backup set.

Important:
  - Set @BackupFile before running.
  - The backup file must be accessible by the SQL Server service account.
  - Review HEADERONLY output and confirm the correct backup set Position.
  - Set @BackupSetPosition when the backup file contains multiple backup sets.
  - VERIFYONLY validates backup readability but does not replace an actual restore test.
*/

SET NOCOUNT ON;

DECLARE @BackupFile nvarchar(4000) = N'T:\DBAScripts_08Aug2026.bak';
DECLARE @BackupSetPosition int = 1;

-- Validate backup file input
IF @BackupFile IS NULL
   OR LTRIM(RTRIM(@BackupFile)) = N''
   OR @BackupFile = N'CHANGE_ME.bak'
BEGIN
    THROW 50000, 'Set @BackupFile to a valid backup file path before running.', 1;
END;

-- Validate backup set position
IF @BackupSetPosition IS NULL
   OR @BackupSetPosition < 1
BEGIN
    THROW 50001, '@BackupSetPosition must be 1 or greater.', 1;
END;

DECLARE @sql nvarchar(max);
DECLARE @EscapedBackupFile nvarchar(max);

-- Escape embedded single quotes in the path
SET @EscapedBackupFile =
    REPLACE(@BackupFile, N'''', N'''''');


-- ============================================================
-- 1. BACKUP HEADER
-- ============================================================
-- Review the Position column returned here.
-- If multiple backup sets exist in the file, update
-- @BackupSetPosition before relying on FILELISTONLY/VERIFYONLY.

SET @sql =
    N'RESTORE HEADERONLY
      FROM DISK = N''' + @EscapedBackupFile + N''';';

PRINT 'Running RESTORE HEADERONLY...';

EXEC sys.sp_executesql @sql;


-- ============================================================
-- 2. BACKUP FILE LIST
-- ============================================================
-- Shows logical database file names required when building
-- RESTORE DATABASE ... WITH MOVE commands.

SET @sql =
    N'RESTORE FILELISTONLY
      FROM DISK = N''' + @EscapedBackupFile + N'''
      WITH FILE = ' 
      + CONVERT(nvarchar(20), @BackupSetPosition) 
      + N';';

PRINT 'Running RESTORE FILELISTONLY...';

EXEC sys.sp_executesql @sql;


-- ============================================================
-- 3. VERIFY BACKUP
-- ============================================================

BEGIN TRY

    SET @sql =
        N'RESTORE VERIFYONLY
          FROM DISK = N''' + @EscapedBackupFile + N'''
          WITH FILE = '
          + CONVERT(nvarchar(20), @BackupSetPosition)
          + N';';

    EXEC sys.sp_executesql @sql;

    SELECT
        'RESTORE VERIFYONLY' AS CheckName,
        'PASS' AS Status,
        @BackupFile AS BackupFile,
        @BackupSetPosition AS BackupSetPosition,
        'SQL Server successfully verified the selected backup set.' AS Details;

END TRY
BEGIN CATCH

    SELECT
        'RESTORE VERIFYONLY' AS CheckName,
        'FAIL' AS Status,
        @BackupFile AS BackupFile,
        @BackupSetPosition AS BackupSetPosition,
        ERROR_MESSAGE() AS Details;

END CATCH;
