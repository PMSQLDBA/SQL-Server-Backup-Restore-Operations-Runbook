/*
HIGH-IMPACT TEMPLATE - POINT-IN-TIME RECOVERY.
DO NOT run until the exact FULL/DIFF/LOG sequence and target time are validated.
This file intentionally contains a non-executable outline rather than guessing your backup chain.

Required sequence:
1) RESTORE DATABASE target FROM full WITH NORECOVERY, MOVE...
2) Optional: RESTORE DATABASE target FROM differential WITH NORECOVERY
3) RESTORE LOG target FROM each log backup in LSN order WITH NORECOVERY
4) Final required log:
   RESTORE LOG target FROM DISK='...' WITH STOPAT='YYYY-MM-DDTHH:MM:SS', RECOVERY

Rules:
- Use a separate target database when possible for validation.
- Verify target time/time zone with incident owner.
- Never skip required log backups.
- Confirm STOPAT lies within the selected log backup.
- Keep the database in NORECOVERY until the final intended restore.
*/
THROW 50000, 'SAFETY STOP: customize a validated restore sequence from the SOP before execution.', 1;
