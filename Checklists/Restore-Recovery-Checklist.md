# Restore / Recovery Checklist

- [ ] Confirm incident/change owner and approved recovery objective.
- [ ] Confirm source database, target database, and target server.
- [ ] Prefer a new target database for validation when practical.
- [ ] Confirm required recovery point and time zone.
- [ ] Inventory FULL / DIFF / LOG backups and validate the intended chain.
- [ ] Run RESTORE HEADERONLY and FILELISTONLY.
- [ ] Confirm logical file names, physical target paths, and free disk capacity.
- [ ] Confirm encryption certificate/key availability when applicable.
- [ ] Confirm SQL Server version/compatibility constraints.
- [ ] Decide RECOVERY vs NORECOVERY for every restore step.
- [ ] Peer-review the complete restore sequence.
- [ ] Confirm application/user impact and access controls.
- [ ] Execute restore while capturing output.
- [ ] Verify database state and restore history.
- [ ] Run integrity checks in an approved window.
- [ ] Validate users/logins, permissions, owner, jobs, integrations, and application connectivity.
- [ ] Obtain business/application validation before declaring recovery complete.
- [ ] Record exact backups used and final recovery point.
