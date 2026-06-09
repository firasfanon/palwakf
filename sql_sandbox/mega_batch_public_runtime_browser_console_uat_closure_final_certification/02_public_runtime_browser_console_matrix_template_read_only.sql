-- 02_public_runtime_browser_console_matrix_template_read_only.sql
-- Read-only template for final public runtime browser/console evidence.

select * from (values
  ('/home', 'open route + hero/breaking/footer + console clean', 'pending_user_browser_console_evidence'),
  ('/home/news', 'list/filter/cards + console clean', 'pending_user_browser_console_evidence'),
  ('/home/news/1963512572', 'detail metadata/body/actions + console clean', 'pending_user_browser_console_evidence'),
  ('/home/announcements', 'list/metrics/filters + console clean', 'pending_user_browser_console_evidence'),
  ('/home/announcements/1295789704', 'detail metadata/body/actions + no loading loop + console clean', 'pending_user_browser_console_evidence'),
  ('/home/services', 'service catalog cards via compatibility wrapper + console clean', 'pending_user_browser_console_evidence')
) as t(route_path, required_evidence, decision);
