-- Mega Batch Public Platform Runtime Consolidation
-- 04_browser_uat_matrix_template_read_only.sql
-- Browser UAT matrix template returned as rows. No DML.

select * from (
  values
    ('/home', 'open route + hero/breaking/footer + console clean', 'pending_user_browser_uat'),
    ('/home/news', 'list/filter/cards + console clean', 'pending_user_browser_uat'),
    ('/home/news/1963512572', 'detail metadata/body/actions + console clean', 'pending_user_browser_uat'),
    ('/home/announcements', 'list/metrics/filters + console clean', 'pending_user_browser_uat'),
    ('/home/announcements/1295789704', 'detail metadata/body/actions + no loading loop + console clean', 'pending_user_browser_uat'),
    ('/home/services', 'service catalog cards via compatibility wrapper + console clean', 'pending_user_browser_uat')
) as t(route_path, required_evidence, decision);
