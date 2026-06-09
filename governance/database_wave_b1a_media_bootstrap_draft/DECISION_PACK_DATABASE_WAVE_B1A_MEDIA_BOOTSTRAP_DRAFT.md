# Decision Pack — Database Wave B-1A Media Bootstrap Draft

## Decision Summary
Media remains blocked for activation, but the platform now has a concrete draft bootstrap contract for review.

## Decisions
| Domain | Decision | Reason |
|---|---|---|
| Media owner | `media_center` remains the future sovereign owner | Confirmed by B-0/B-1A readiness evidence |
| Public media tables | preserve unchanged | runtime/RLS risk remains high |
| Compatibility wrappers | not activated | media_center is still under-bootstrapped |
| Extraction | not authorized | no RLS/workflow certification yet |
| Services | closure preserved | B-1A services compatibility is already certified |
| Locations | blocked | public vs GIS authority gate still open |
| Waqf boundary | forbidden | critical read-only boundary |

## Certification state
`media-bootstrap-draft-ready / media-activation-blocked / extraction-blocked / review-required`

## Required approval before future apply
A future SQL apply may only be prepared after confirming:
1. Required columns and type model for `media_center.content_items`.
2. RLS actor contract and admin/editor roles.
3. Editorial workflow transitions.
4. Public published-only exposure policy.
5. Mapping from all existing public media shapes.
6. No break to current public pages and admin media pages.
