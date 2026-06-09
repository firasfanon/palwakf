-- Read-only marker for public main page route inventory.
select * from (values
  ('/home', 'canonical', 'main homepage'),
  ('/home/news', 'canonical', 'news list'),
  ('/home/news/:id', 'canonical', 'news detail'),
  ('/home/announcements', 'canonical', 'announcement list'),
  ('/home/announcements/:id', 'canonical', 'announcement detail'),
  ('/home/activities', 'canonical', 'activities list'),
  ('/home/gallery', 'canonical', 'gallery/media'),
  ('/home/services', 'canonical', 'services catalog'),
  ('/home/press-releases', 'canonical', 'press releases'),
  ('/home/zakat', 'canonical', 'zakat public tool'),
  ('/home/chat', 'canonical', 'public assistant'),
  ('/zakat', 'legacy_alias', 'must redirect to /home/zakat'),
  ('/press-releases', 'legacy_alias', 'must redirect to /home/press-releases'),
  ('/chat', 'legacy_alias', 'must redirect to /home/chat'),
  ('/media', 'legacy_alias', 'must redirect to /home/gallery'),
  ('/gallery', 'legacy_alias', 'must redirect to /home/gallery')
) as t(route_path, route_role, note);
