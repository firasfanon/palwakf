-- Database Wave B-1A Legacy Public Media Boundary — READ ONLY
select 'legacy_public_media_boundary' as section, x.object_name,
  to_regclass('public.' || x.object_name) is not null as legacy_public_table_exists,
  case when to_regclass('public.' || x.object_name) is not null then 'legacy_public_table_preserved' else 'legacy_public_table_missing_review' end as boundary_decision
from (values ('activities'),('announcements'),('news_articles'),('news'),('breaking_news'),('media_gallery_items')) as x(object_name)
order by x.object_name;
