-- Read-only marker for Public Route Canonicalization.
-- Routing is a Flutter/GoRouter contract; this SQL intentionally performs no DDL/DML.
select 'public_route_canonicalization' as section,
       'PUBLIC_ROUTE_CANONICALIZATION_APPLIED_BROWSER_UAT_REQUIRED' as decision,
       'public routes canonical namespace is /home/*; root public routes are legacy aliases only' as note;
