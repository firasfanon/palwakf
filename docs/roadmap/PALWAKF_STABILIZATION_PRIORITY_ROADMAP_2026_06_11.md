# PalWakf Stabilization Governance Priority Pack

Date: 2026-06-11  
Scope: Platform stabilization, CMS data contracts, governed attachments, RBAC identity, smoke testing, and technical services operations.

## Purpose

This pack formalizes the five approved priorities for the next PalWakf stabilization phase:

1. Data Contract Validation
2. Governed Attachments Design
3. RBAC Identity Source of Truth
4. Smoke Test Suite
5. Technical Services Runbook

The pack is documentation-first and governance-first. It does not execute SQL, modify RLS, change production permissions, or introduce service-role keys into Flutter.

## Priority Order

| Priority | Area | Target Outcome |
|---|---|---|
| P1 | Data Contract Validation | Prevent PostgREST 400 failures caused by invalid payload/database mismatch |
| P2 | Governed Attachments Design | Replace ad-hoc attachment fields with governed attachment registry and audit model |
| P3 | RBAC Identity Source of Truth | Clarify official admin identity and permission authority |
| P4 | Smoke Test Suite | Move from manual-only evidence to repeatable integration checks |
| P5 | Technical Services Runbook | Convert platform_technical features into an official operational practice |

## Governance Boundary

- No SQL in this pack.
- No RLS mutation in this pack.
- No production approval in this pack.
- No direct service-role usage in Flutter.
- Any future SQL/RLS/permission change requires an independent authorization gate.
