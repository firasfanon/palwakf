-- Database Wave B-1A — Browser Click-through Pending Gate
-- Read-only values-only matrix.

select * from (values
  ('browser_clickthrough_gate','/home','pending','Need screenshot plus console clean evidence.'),
  ('browser_clickthrough_gate','/home/news','pending','Need nonzero news list screenshot.'),
  ('browser_clickthrough_gate','first_news_detail','pending','Need detail page opened from rendered card.'),
  ('browser_clickthrough_gate','/home/announcements','pending','Need nonzero announcements list screenshot.'),
  ('browser_clickthrough_gate','first_announcement_detail','pending','Need detail page opened from rendered card.'),
  ('browser_clickthrough_gate','browser_console_review','pending','Need no repeated runtime blockers.'),
  ('browser_clickthrough_gate','production_gate','blocked','Production remains not approved until all pending checks pass.')
) as t(section, route_or_action, result, note);
