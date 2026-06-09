-- Expected route matrix marker; read-only constant output.
select * from (values
('/home/gallery','canonical gallery route','pending_browser_console_uat'),
('/home/media','legacy alias to /home/gallery','pending_browser_console_uat'),
('/gallery','legacy alias to /home/gallery','pending_browser_console_uat'),
('/media','legacy alias to /home/gallery','pending_browser_console_uat'),
('/zakat','legacy alias to /home/zakat','pending_browser_console_uat'),
('/home/zakat','canonical zakat route','pending_browser_console_uat'),
('/press-releases','legacy alias to /home/press-releases','pending_browser_console_uat'),
('/home/press-releases','canonical press releases route','pending_browser_console_uat'),
('/home/services','canonical services route','pending_browser_console_uat'),
('/home/activities','canonical activities route','pending_browser_console_uat')
) as t(route_path, expected_behavior, decision);
