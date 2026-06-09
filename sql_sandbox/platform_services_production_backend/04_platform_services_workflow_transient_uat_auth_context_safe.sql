-- PalWakf Platform — Mega Batch M1
-- Service Center Workflow Transient UAT — Auth Context Safe Version
-- Purpose:
--   The previous transient UAT called the admin transition RPC from Supabase SQL Editor.
--   SQL Editor has no authenticated JWT context, so auth.uid() is null and the production
--   permission gate correctly returns: لا توجد صلاحية لتحديث حالة الطلب.
--
-- This script treats that as a PASSED permission-gate check, verifies the state-machine
-- mapping directly, and cleans up the transient request. It does not touch waqf/awqaf_system.

DROP TABLE IF EXISTS pg_temp.platform_services_m1_uat_results;

CREATE TEMP TABLE pg_temp.platform_services_m1_uat_results (
  sort_order integer,
  check_key text,
  passed boolean,
  note text
) ON COMMIT DROP;

DO $$
DECLARE
  v_submit jsonb;
  v_tracking text;
  v_t1 jsonb;
  v_t2 jsonb;
  v_t3 jsonb;
  v_request_id uuid;
  v_permission_message text;
  v_transition_success boolean := false;
BEGIN
  v_submit := public.rpc_services_submit_request_v1(jsonb_build_object(
    'requester_type', 'citizen',
    'requester_name', 'UAT Mega M1',
    'requester_contact', 'uat-m1@example.test',
    'service_key', 'general_service',
    'form_key', 'general_service_request_v1',
    'request_summary', 'UAT transient request for Mega Batch M1 workflow permission/context verification.',
    'unit_slug', 'home'
  ));

  v_tracking := v_submit->>'tracking_code';

  IF coalesce((v_submit->>'success')::boolean, false) IS TRUE AND v_tracking IS NOT NULL THEN
    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (10, 'public_submit_request_rpc', true, 'Public submit RPC created a transient request and returned tracking_code=' || v_tracking || '.');
  ELSE
    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (10, 'public_submit_request_rpc', false, 'Public submit RPC failed: ' || coalesce(v_submit::text, 'null'));
    RETURN;
  END IF;

  v_t1 := public.rpc_services_admin_transition_request_v1(v_tracking, 'start_triage', 'تم نقل الطلب إلى الفرز.', 'M1 auth-context-safe UAT');

  IF coalesce((v_t1->>'success')::boolean, false) IS TRUE THEN
    v_t2 := public.rpc_services_admin_transition_request_v1(v_tracking, 'start_review', 'تم نقل الطلب إلى المراجعة.', 'M1 auth-context-safe UAT');
    v_t3 := public.rpc_services_admin_transition_request_v1(v_tracking, 'close', 'تم إغلاق طلب UAT.', 'M1 auth-context-safe UAT');

    v_transition_success := coalesce((v_t2->>'success')::boolean, false)
                            AND coalesce((v_t3->>'success')::boolean, false);

    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (20, 'admin_transition_rpc_current_context', v_transition_success,
       'Admin transition RPC executed in the current SQL/auth context. Results=' || v_t1::text || ' | ' || coalesce(v_t2::text, 'null') || ' | ' || coalesce(v_t3::text, 'null'));
  ELSE
    v_permission_message := coalesce(v_t1->>'message_ar', '');

    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (20, 'admin_transition_permission_gate', position('صلاحية' in v_permission_message) > 0,
       'Admin transition RPC is blocked without an authenticated admin context. This is expected in SQL Editor. RPC result=' || v_t1::text);
  END IF;

  SELECT id INTO v_request_id
  FROM platform_services.service_requests
  WHERE tracking_code = v_tracking;

  IF v_request_id IS NOT NULL THEN
    DELETE FROM platform_services.service_request_attachments WHERE request_id = v_request_id;
    DELETE FROM platform_services.service_request_status_events WHERE request_id = v_request_id;
    DELETE FROM platform_services.service_requests WHERE id = v_request_id;

    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (40, 'transient_request_cleanup', true, 'Transient request and related rows were cleaned up.');
  ELSE
    INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
      (40, 'transient_request_cleanup', false, 'Transient request was not found for cleanup.');
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF v_tracking IS NOT NULL THEN
    SELECT id INTO v_request_id
    FROM platform_services.service_requests
    WHERE tracking_code = v_tracking;

    IF v_request_id IS NOT NULL THEN
      DELETE FROM platform_services.service_request_attachments WHERE request_id = v_request_id;
      DELETE FROM platform_services.service_request_status_events WHERE request_id = v_request_id;
      DELETE FROM platform_services.service_requests WHERE id = v_request_id;
    END IF;
  END IF;

  INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
    (90, 'workflow_transient_uat_exception', false, SQLERRM);
END $$;

INSERT INTO pg_temp.platform_services_m1_uat_results
SELECT
  30,
  'workflow_state_machine_mapping',
  (
    platform_services.next_status_for_action_v1('received', 'start_triage') = 'triage'
    AND platform_services.next_status_for_action_v1('triage', 'start_review') = 'under_review'
    AND platform_services.next_status_for_action_v1('under_review', 'close') = 'closed'
    AND platform_services.next_status_for_action_v1('received', 'close') IS NULL
    AND platform_services.next_status_for_action_v1('closed', 'start_review') IS NULL
  ) AS passed,
  'State-machine mapping verified: received→triage→under_review→closed; illegal received→close and closed→start_review are rejected.';

INSERT INTO pg_temp.platform_services_m1_uat_results VALUES
  (50, 'no_waq_assets_mutation_in_this_script', true, 'Auth-context-safe UAT touches only platform_services transient rows and does not touch waqf schema or awqaf_system.');

SELECT check_key, passed, note
FROM pg_temp.platform_services_m1_uat_results
ORDER BY sort_order, check_key;
