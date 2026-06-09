# Internal Assistant Scope Update — N2.27

The internal assistant may explain schema ownership decisions and guide administrators through read-only inventory, UAT, and evidence collection.

It must not recommend deleting, moving, or renaming database tables without approved migration evidence.

It must treat:

- `site_content` as the target site-content owner,
- `media_center` as the target media-center owner,
- `platform_services` as the service-center owner,
- `public` as wrapper/compatibility surface.
