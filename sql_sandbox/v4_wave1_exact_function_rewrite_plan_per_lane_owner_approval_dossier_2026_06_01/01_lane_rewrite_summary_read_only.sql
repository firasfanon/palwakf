with lanes(lane_key, domain_key, candidate_count, priority_order, owner_group, current_status) as (
  values
    ('LANE_A_PLATFORM_ACCESS','platform_access',24,1,'platform_access_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_C_MEDIA_CENTER','media_center',14,2,'media_center_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_B_SERVICE_NAVIGATION','platform_navigation_services',11,3,'platform_navigation_owner/platform_services_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_E_CORE_GIS_LOOKUP','core_gis_lookup',7,4,'core_gis_owner/gis_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_H_COMPLAINTS','complaints',7,4,'complaints_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_I_AWQAF_SYSTEM','awqaf_system',6,4,'awqaf_system_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_D_DOCUMENT_WAQF_CMS','cms_documents',4,4,'cms_waqf_joint_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_J_WAQF_RELIGIOUS_ZAKAT','waqf_religious_zakat',4,4,'waqf/religious/zakat owners','OWNER_APPROVAL_PENDING')
)
select
  'v4_wave1_lane_rewrite_summary' as section,
  *,
  false as rewrite_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only
from lanes
order by priority_order, lane_key;
