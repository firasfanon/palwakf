# Governing Contract Appendix — Technical Services Real Operations

This appendix makes the Platform Admin Technical Services module a governed operational subsystem.

## Binding rules

1. Backup and restore are not executable from Flutter.
2. Flutter may create governed technical service requests only through approved RPCs.
3. Maintenance mode activation requires a separate backend flag and approval flow.
4. Health checks are read/catalog checks and must not mutate sovereign business data.
5. Deployment records are metadata records only; deploy execution stays in CI/CD/Vercel.
6. Audit events are append-only from the user interface perspective.
7. `service_role` must never be embedded in Flutter or browser-executed code.
8. Production approval remains a separate gate.
