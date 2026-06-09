-- Database Ownership Wave A — DO-NOT-RUN retirement marker
-- SQL 42: read-only list of retired/blocked SQL files.

select *
from (
  values
    ('SQL29', 'retired_after_runner_relation_core_failure', 'DO_NOT_RUN'),
    ('SQL37', 'access_helper_replacement_cancelled_safe_stop', 'DO_NOT_RUN'),
    ('SQL38', 'post_apply_validation_not_applicable_without_sql37', 'DO_NOT_RUN'),
    ('SQL39', 'rls_browser_matrix_not_execution_gate_in_wave_a', 'DO_NOT_RUN'),
    ('SQL40', 'next_gate_superseded_by_safe_stop', 'DO_NOT_RUN'),
    ('SQL02', 'guarded_execution_blocked', 'DO_NOT_RUN'),
    ('SQL03', 'guarded_execution_blocked', 'DO_NOT_RUN'),
    ('SQL04', 'guarded_execution_blocked', 'DO_NOT_RUN')
) as t(sql_file, reason, decision);
