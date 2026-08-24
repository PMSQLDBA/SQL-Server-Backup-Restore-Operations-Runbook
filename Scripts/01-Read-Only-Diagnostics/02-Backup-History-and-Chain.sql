/*
Purpose: Inspect recent backup history and LSN metadata used when planning restores.
Read-only: YES
Set @DatabaseName before use.
*/
SET NOCOUNT ON;
DECLARE @DatabaseName sysname = N'CHANGE_ME';

IF @DatabaseName = N'CHANGE_ME'
    THROW 50000, 'Set @DatabaseName before running.', 1;

SELECT TOP (200)
       bs.backup_set_id,
       bs.database_name,
       CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFF' WHEN 'L' THEN 'LOG' ELSE bs.type END AS BackupType,
       bs.is_copy_only,
       bs.backup_start_date,
       bs.backup_finish_date,
       bs.first_lsn,
       bs.last_lsn,
       bs.database_backup_lsn,
       bs.checkpoint_lsn,
       bs.differential_base_lsn,
       bs.recovery_model,
       bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
LEFT JOIN msdb.dbo.backupmediafamily AS bmf
  ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = @DatabaseName
ORDER BY bs.backup_finish_date DESC, bs.backup_set_id DESC;
