# Troubleshooting Guide

## Backup cannot open device
Check path spelling, SQL Server service-account permissions, network/share availability, and free space. Remember the path is resolved from the SQL Server host, not necessarily your workstation.

## Log backup fails under SIMPLE
Transaction log backups are not supported in SIMPLE recovery model. Do not change recovery model just to make a script succeed; understand the business recovery requirement first.

## Differential restore does not match base
Use backup metadata to identify the correct differential base. Do not force an unrelated differential into a restore sequence.

## Log restore reports LSN mismatch
A required log backup may be missing, backups may be out of order, or the selected full/differential is from a different chain. Rebuild the sequence using backup metadata.

## Database remains RESTORING
This is expected after `NORECOVERY`. Continue the intended sequence, or issue recovery only when you are certain no additional backups need to be applied.

## Restore wants to overwrite files/database
Stop and verify the target. This package's new-database template refuses an existing database by default. Do not add `WITH REPLACE` casually.

## Encrypted backup cannot restore
Confirm the required certificate/asymmetric key and private key are available on the target server before recovery is needed.

## Restore is slow
Review storage throughput, backup compression, file initialization behavior, competing workload, backup media, and target capacity. Avoid making emergency tuning changes without understanding impact.
