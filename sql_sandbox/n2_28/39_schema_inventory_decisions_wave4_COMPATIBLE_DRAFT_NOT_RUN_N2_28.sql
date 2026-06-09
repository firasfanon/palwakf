-- N2.28 DRAFT ONLY - DO NOT RUN WITHOUT REVIEW
-- Purpose: This is a placeholder for a compatible Wave 4 decision update.
-- Before writing decisions, run 38_schema_inventory_decisions_shape_READ_ONLY_N2_28.sql.
-- The previous draft failed because it assumed a `schema_name` column.
-- Choose one governed path:
--   A) Add canonical columns through approved DDL.
--   B) Write DML using the actual existing columns.
-- This file intentionally performs no DDL/DML.
select 'DRAFT_NOT_RUN: inspect platform.schema_inventory_decisions shape first' as status;
