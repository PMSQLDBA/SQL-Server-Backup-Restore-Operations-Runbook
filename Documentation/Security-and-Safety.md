# Security and Safety

- Treat backup files as sensitive copies of production data.
- Protect credentials, encryption certificates/keys, paths, and operational evidence.
- Never publish real server names, file shares, customer names, or internal ticket data in examples.
- Keep read-only diagnostics separate from execution scripts.
- Require peer review for production restores.
- Prefer new target names and explicit MOVE paths.
- The supplied restore template intentionally does not use WITH REPLACE.
- The point-in-time template intentionally refuses execution until a validated chain is written.
- Tail-log strategy must be chosen for the actual incident; do not blindly add NORECOVERY/NO_TRUNCATE.
