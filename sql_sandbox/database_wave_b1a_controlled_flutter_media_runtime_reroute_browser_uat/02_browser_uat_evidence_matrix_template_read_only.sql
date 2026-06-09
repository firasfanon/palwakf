-- Database Wave B-1A — Browser UAT Evidence Matrix Template
-- Read-only matrix for recording browser evidence outside the database.

select * from (values
  ('browser_uat_required','/home','news_section_nonzero','pending_user_screenshot'),
  ('browser_uat_required','/home','announcements_section_nonzero','pending_user_screenshot'),
  ('browser_uat_required','/home/news','news_list_nonzero','pending_user_screenshot'),
  ('browser_uat_required','click_first_news_card','news_detail_opens','pending_user_screenshot'),
  ('browser_uat_required','/home/announcements','announcements_list_nonzero','pending_user_screenshot'),
  ('browser_uat_required','click_first_announcement_card','announcement_detail_opens','pending_user_screenshot'),
  ('browser_uat_required','browser_console','no_runtime_blockers','pending_console_screenshot'),
  ('browser_uat_required','activities','not_claimed_as_rerouted','must_remain_true'),
  ('browser_uat_required','gallery','not_claimed_as_rerouted','must_remain_true')
) as t(section, route_or_action, check_key, required_evidence);
