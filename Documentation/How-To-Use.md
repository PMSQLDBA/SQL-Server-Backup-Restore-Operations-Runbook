# How to Use

1. Start with read-only diagnostics.
2. Identify the recovery objective: routine backup, test restore, accidental change recovery, corruption recovery, migration, or DR.
3. Use the appropriate checklist.
4. Inspect backup headers/file lists.
5. Build the complete restore sequence on paper/in a reviewed script before executing.
6. For change templates, replace every `CHANGE_ME` value.
7. Keep `@Approved = 0` until review is complete.
8. Prefer restoring to a new database for validation when possible.
9. Capture evidence and perform post-restore verification.

## Important
`WITH CHECKSUM` can detect some I/O/page checksum problems during backup/restore, but it is not a substitute for restore testing or DBCC CHECKDB.
