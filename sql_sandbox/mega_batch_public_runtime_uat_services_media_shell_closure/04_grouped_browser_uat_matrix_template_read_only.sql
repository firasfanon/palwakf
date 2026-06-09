-- Mega Batch Public Runtime UAT + Services/Media Shell Closure
-- 04_grouped_browser_uat_matrix_template_read_only.sql
-- READ ONLY template to keep UAT grouped in a mega batch.

select * from (values
  ('/home', 'open route + hero/breaking/footer + console clean', 'pending_grouped_browser_uat'),
  ('/home/news', 'list/filter/cards + console clean', 'pending_grouped_browser_uat'),
  ('/home/news/1963512572', 'detail metadata/body/actions + console clean', 'pending_grouped_browser_uat'),
  ('/home/announcements', 'list/metrics/filters + console clean', 'pending_grouped_browser_uat'),
  ('/home/announcements/1295789704', 'detail metadata/body/actions + no loading loop + console clean', 'pending_grouped_browser_uat'),
  ('/home/services', 'service catalog cards via compatibility wrapper + console clean', 'pending_grouped_browser_uat')
) as uat(route_path, required_evidence, decision);
