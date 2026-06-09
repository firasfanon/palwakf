select * from (values
  ('LANE_D_DOCUMENT_WAQF_CMS','D001-D004','CMS/Waqf document and waqf asset read queue','EXACT_BODY_REVIEW_REQUIRED','cms_waqf_joint_owner and waqf_owner sign-off'),
  ('LANE_E_CORE_GIS_LOOKUP','E001-E007','core/gis lookup/search functions','REFERENCE_LOOKUP_REVIEW_REQUIRED','lookup smoke + core/gis owner sign-off'),
  ('LANE_H_COMPLAINTS','H001-H007','complaint track/list/trigger/purge functions','WRITE_RISK_TRIAGE_REQUIRED','complaints owner sign-off + purge negative UAT'),
  ('LANE_I_AWQAF_SYSTEM','I001-I006','Awqaf Assist/content/settings/unit pages','OWNER_SYSTEM_REVIEW_REQUIRED','awqaf_system owner approval + analyzer/runtime gate'),
  ('LANE_J_WAQF_RELIGIOUS_ZAKAT','J001-J004','waqf supervision/category/zakat readiness','DOMAIN_OWNER_UAT_REQUIRED','waqf/religious/zakat owner UAT')
) as t(lane_key, candidate_range, area, recommended_decision, required_evidence)
;
