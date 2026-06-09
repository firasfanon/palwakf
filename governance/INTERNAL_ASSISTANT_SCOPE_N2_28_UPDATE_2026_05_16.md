# Internal Assistant Scope Update — N2.28

The internal assistant must treat database ownership decisions as governed architecture facts. It may explain, search, and summarize schema inventory and migration decisions, but it must not recommend table deletion or operational table movement without dependency, RLS, RPC, and Flutter usage evidence.

The assistant must distinguish:

- `site_content` for public site/page management,
- `media_center` for media center ownership,
- `platform_services` for service center ownership,
- `core` for organizational units,
- `public` as wrapper/compatibility layer.
