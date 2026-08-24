# SQL Server Backup & Restore Operations Runbook

Version: 1.0

A practical operations package for SQL Server DBAs covering backup validation, full/differential/log backups, restore planning, restore-to-new-database, point-in-time recovery, tail-log backup decision guidance, and post-restore verification.

## Safety model

This package deliberately separates:

- `Scripts/01-Read-Only-Diagnostics` - inspection and validation only.
- `Scripts/02-Change-Execution` - commands that can create backup files, restore databases, or change database state. These are templates and contain deliberate safety stops/placeholders.

Never run change-execution scripts blindly. Review every variable, file path, database name, recovery requirement, and restore plan first. Test in non-production.

## Quick start

1. Read `SOP/SQL-Server-Backup-Restore-Operations-Runbook.pdf`.
2. Review `Documentation/Prerequisites-and-Permissions.md`.
3. Run the read-only diagnostics.
4. Complete the relevant checklist.
5. Copy a change-execution template and customize it for the approved operation.
6. Peer-review the final commands before production execution.
7. Validate the restored/recovered database.

## Package contents

- Backup inventory and backup-age diagnostics
- Backup chain/history review
- Restore header/file-list validation
- FULL, DIFF, LOG backup templates
- Restore-to-new-database template
- Point-in-time restore template
- Tail-log backup template with safeguards
- Post-restore verification
- Production checklists
- Troubleshooting guide
- SOP PDF and sample output

## Compatibility

Designed around SQL Server 2016+ concepts and common supported SQL Server releases. Some syntax/options vary by version, edition, platform, storage target, encryption configuration, and managed service. Validate against your exact environment.

## License

See `LICENSE.txt`. This is an original operational template package, not Microsoft documentation.
