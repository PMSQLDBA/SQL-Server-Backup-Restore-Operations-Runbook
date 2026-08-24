# Prerequisites and Permissions

## Skills
This package assumes the operator understands SQL Server backup/recovery concepts, recovery models, LSN-based log chains, and the impact of RESTORE.

## Access
Exact permissions depend on the organization and SQL Server version/configuration. Common requirements include:
- Access to msdb backup/restore history for diagnostics.
- Appropriate BACKUP DATABASE / BACKUP LOG permission for backup execution.
- RESTORE permission for restore execution; creating/restoring databases commonly requires elevated server permissions.
- SQL Server service account access to backup and target file locations.

Do not grant broad sysadmin access solely to make these templates work. Follow least-privilege and your organization's access process.

## Before production use
- Test on non-production.
- Verify storage, encryption, retention, and security requirements.
- Confirm backup files are protected as sensitive data.
- Validate version/platform-specific syntax and capabilities.
