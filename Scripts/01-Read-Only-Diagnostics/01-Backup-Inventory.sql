/*
Purpose: Review recovery model and latest backup times for online databases.
Read-only: YES
Required: msdb backup history access; VIEW SERVER STATE may improve broader diagnostics.
*/
SET NOCOUNT ON;

;WITH b AS (
    SELECT database_name,
           MAX(CASE WHEN type='D' THEN backup_finish_date END) AS LastFull,
           MAX(CASE WHEN type='I' THEN backup_finish_date END) AS LastDiff,
           MAX(CASE WHEN type='L' THEN backup_finish_date END) AS LastLog
    FROM msdb.dbo.backupset
    WHERE is_copy_only = 0
    GROUP BY database_name
)
SELECT d.name AS DatabaseName,
       d.state_desc,
       d.recovery_model_desc,
       b.LastFull,
       b.LastDiff,
       b.LastLog,
       CASE
         WHEN d.name = 'tempdb' THEN 'INFO'
         WHEN b.LastFull IS NULL THEN 'WARNING'
         ELSE 'INFO'
       END AS ReviewStatus
FROM sys.databases AS d
LEFT JOIN b ON b.database_name = d.name
ORDER BY d.name;
