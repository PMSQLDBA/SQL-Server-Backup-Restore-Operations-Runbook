# Backup Operation Checklist

- [ ] Confirm database and environment.
- [ ] Confirm backup type: FULL / DIFF / LOG.
- [ ] Confirm recovery model and business backup policy.
- [ ] Confirm destination path, free capacity, retention, and SQL Server service-account access.
- [ ] Confirm encryption/compression requirements for the environment.
- [ ] Confirm no conflicting maintenance or incident activity.
- [ ] Review the generated BACKUP command.
- [ ] Obtain required change/peer approval.
- [ ] Execute and capture start/end time and output.
- [ ] Confirm backup completed successfully.
- [ ] Validate backup metadata in msdb.
- [ ] Perform restore testing according to organizational policy; a successful BACKUP command alone does not prove recoverability.
- [ ] Record evidence/ticket notes.
