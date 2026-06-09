// Platform Development 10H — Actual Negative UAT Evidence Bundle Runner
// Runs real denied owner-write RPC attempts against Supabase using only the anon key.
// No service_role, no elevated secret, no auth.users mutation.
//
// Usage from project root:
//   dart run tools/platform_development_10h/owner_write_rpc_negative_uat_runner.dart
//
// Required environment variables are documented in ENV_TEMPLATE_PLATFORM_DEVELOPMENT_10H.env.example.

import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

const _rpcNames = <String>[
  'rpc_core_admin_user_profile_update_v1',
  'rpc_core_admin_user_link_v1',
  'rpc_core_admin_user_deactivate_v1',
  'rpc_platform_system_register_v1',
  'rpc_platform_user_role_upsert_v1',
  'rpc_platform_user_role_delete_v1',
  'rpc_platform_user_permission_grant_v1',
  'rpc_platform_user_permission_revoke_v1',
];

const _zeroUuid = '00000000-0000-0000-0000-000000000001';

String? _env(String name) {
  final value = Platform.environment[name];
  if (value == null || value.trim().isEmpty) return null;
  return value.trim();
}

String _requiredEnv(String name, List<String> missing) {
  final value = _env(name);
  if (value == null) missing.add(name);
  return value ?? '';
}

String _timestamp() => DateTime.now()
    .toUtc()
    .toIso8601String()
    .replaceAll(':', '')
    .replaceAll('.', '_');

Map<String, dynamic> _patch(String caseKey) => <String, dynamic>{
  'operation': 'negative_uat_$caseKey',
  'correlation_id':
      'platform_development_10h_${DateTime.now().millisecondsSinceEpoch}',
  'request_id': 'negative_uat_$caseKey',
};

class AttemptSpec {
  const AttemptSpec({
    required this.actor,
    required this.caseKey,
    required this.rpc,
    required this.params,
    required this.expectedDenial,
  });

  final String actor;
  final String caseKey;
  final String rpc;
  final Map<String, dynamic> params;
  final String expectedDenial;
}

class ActorSession {
  ActorSession({required this.actor, required this.client, this.email});

  final String actor;
  final SupabaseClient client;
  final String? email;
}

Future<Map<String, dynamic>> _runAttempt(
  ActorSession session,
  AttemptSpec spec,
) async {
  final started = DateTime.now().toUtc();
  try {
    final response = await session.client.rpc(spec.rpc, params: spec.params);
    final normalized = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{'raw_response': response?.toString()};
    final successValue = normalized['success'];
    final denied =
        successValue == false ||
        (normalized['message']?.toString().toLowerCase().contains('denied') ??
            false) ||
        (normalized['message_ar']?.toString().contains('رفض') ?? false);
    return <String, dynamic>{
      'actor': spec.actor,
      'case_key': spec.caseKey,
      'rpc': spec.rpc,
      'expected': spec.expectedDenial,
      'started_at_utc': started.toIso8601String(),
      'finished_at_utc': DateTime.now().toUtc().toIso8601String(),
      'denied': denied,
      'unsafe_success': !denied,
      'response_shape': normalized,
    };
  } on PostgrestException catch (error) {
    return <String, dynamic>{
      'actor': spec.actor,
      'case_key': spec.caseKey,
      'rpc': spec.rpc,
      'expected': spec.expectedDenial,
      'started_at_utc': started.toIso8601String(),
      'finished_at_utc': DateTime.now().toUtc().toIso8601String(),
      'denied': true,
      'unsafe_success': false,
      'error_type': 'PostgrestException',
      'error_code': error.code,
      'error_message': error.message,
      'error_details': error.details,
    };
  } on AuthException catch (error) {
    return <String, dynamic>{
      'actor': spec.actor,
      'case_key': spec.caseKey,
      'rpc': spec.rpc,
      'expected': spec.expectedDenial,
      'started_at_utc': started.toIso8601String(),
      'finished_at_utc': DateTime.now().toUtc().toIso8601String(),
      'denied': true,
      'unsafe_success': false,
      'error_type': 'AuthException',
      'error_message': error.message,
      'error_status_code': error.statusCode,
    };
  } catch (error, stackTrace) {
    return <String, dynamic>{
      'actor': spec.actor,
      'case_key': spec.caseKey,
      'rpc': spec.rpc,
      'expected': spec.expectedDenial,
      'started_at_utc': started.toIso8601String(),
      'finished_at_utc': DateTime.now().toUtc().toIso8601String(),
      'denied': true,
      'unsafe_success': false,
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'stack_trace_head': stackTrace.toString().split('\n').take(5).join('\n'),
    };
  }
}

Future<ActorSession> _anonymousSession(String url, String anonKey) async {
  return ActorSession(actor: 'anonymous', client: SupabaseClient(url, anonKey));
}

Future<ActorSession> _signedInSession({
  required String actor,
  required String url,
  required String anonKey,
  required String email,
  required String password,
}) async {
  final client = SupabaseClient(url, anonKey);
  await client.auth.signInWithPassword(email: email, password: password);
  return ActorSession(actor: actor, client: client, email: email);
}

List<AttemptSpec> _anonymousAttempts() {
  final patch = _patch('anonymous');
  return <AttemptSpec>[
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_core_admin_user_profile_update_v1',
      params: {'p_target_user_id': _zeroUuid, 'p_patch': patch},
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_core_admin_user_link_v1',
      params: {'p_target_user_id': _zeroUuid, 'p_patch': patch},
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_core_admin_user_deactivate_v1',
      params: {'p_target_user_id': _zeroUuid, 'p_patch': patch},
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_platform_system_register_v1',
      params: {
        'p_system_key': 'negative_uat_anon_forbidden',
        'p_payload': patch,
      },
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_platform_user_role_upsert_v1',
      params: {
        'p_target_user_id': _zeroUuid,
        'p_system_key': 'platformAdmin',
        'p_role_key': 'superuser',
        'p_payload': patch,
      },
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_platform_user_role_delete_v1',
      params: {
        'p_target_user_id': _zeroUuid,
        'p_system_key': 'platformAdmin',
        'p_payload': patch,
      },
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_platform_user_permission_grant_v1',
      params: {
        'p_target_user_id': _zeroUuid,
        'p_system_key': 'platformAdmin',
        'p_permission_key': 'manage_users',
        'p_payload': patch,
      },
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
    AttemptSpec(
      actor: 'anonymous',
      caseKey: 'anonymous_denied_all_owner_write_rpcs',
      rpc: 'rpc_platform_user_permission_revoke_v1',
      params: {
        'p_target_user_id': _zeroUuid,
        'p_system_key': 'platformAdmin',
        'p_permission_key': 'manage_users',
        'p_payload': patch,
      },
      expectedDenial: 'anon has no execute privilege after 10C',
    ),
  ];
}

List<AttemptSpec> _actorAttempts({
  required String actor,
  required String targetUserId,
  required String systemKey,
  required String roleKey,
  required String permissionKey,
  required String selfUserId,
}) {
  final patch = _patch(actor);
  switch (actor) {
    case 'unauthorized_authenticated_user':
      return <AttemptSpec>[
        AttemptSpec(
          actor: actor,
          caseKey: 'unauthorized_denied_profile_update',
          rpc: 'rpc_core_admin_user_profile_update_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_patch': {...patch, 'name': 'NEGATIVE_UAT_FORBIDDEN'},
          },
          expectedDenial:
              'SQL-level actor guard denies unauthorized profile update',
        ),
        AttemptSpec(
          actor: actor,
          caseKey: 'unauthorized_denied_role_upsert',
          rpc: 'rpc_platform_user_role_upsert_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_system_key': systemKey,
            'p_role_key': roleKey,
            'p_payload': patch,
          },
          expectedDenial:
              'SQL-level actor guard denies unauthorized role upsert',
        ),
      ];
    case 'scoped_user':
      return <AttemptSpec>[
        AttemptSpec(
          actor: actor,
          caseKey: 'scoped_user_denied_out_of_scope_role_grant',
          rpc: 'rpc_platform_user_role_upsert_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_system_key': systemKey,
            'p_role_key': roleKey,
            'p_payload': patch,
          },
          expectedDenial:
              'Scoped user cannot grant role outside permitted system scope',
        ),
        AttemptSpec(
          actor: actor,
          caseKey: 'scoped_user_denied_out_of_scope_permission_grant',
          rpc: 'rpc_platform_user_permission_grant_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_system_key': systemKey,
            'p_permission_key': permissionKey,
            'p_payload': patch,
          },
          expectedDenial: 'Scoped user cannot grant out-of-scope permission',
        ),
      ];
    case 'unit_admin':
      return <AttemptSpec>[
        AttemptSpec(
          actor: actor,
          caseKey: 'unit_admin_denied_platform_system_register',
          rpc: 'rpc_platform_system_register_v1',
          params: {
            'p_system_key': 'negative_uat_unit_admin_forbidden_system',
            'p_payload': {...patch, 'title_ar': 'اختبار رفض'},
          },
          expectedDenial: 'Unit admin cannot register platform-wide systems',
        ),
        AttemptSpec(
          actor: actor,
          caseKey: 'unit_admin_denied_platform_wide_role_upsert',
          rpc: 'rpc_platform_user_role_upsert_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_system_key': 'platformAdmin',
            'p_role_key': roleKey,
            'p_payload': patch,
          },
          expectedDenial: 'Unit admin cannot mutate platform-wide RBAC',
        ),
      ];
    case 'platform_admin':
      return <AttemptSpec>[
        AttemptSpec(
          actor: actor,
          caseKey: 'platform_admin_denied_superuser_grant',
          rpc: 'rpc_core_admin_user_profile_update_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_patch': {...patch, 'is_superuser': true},
          },
          expectedDenial: 'Platform admin cannot grant superuser status',
        ),
        AttemptSpec(
          actor: actor,
          caseKey: 'platform_admin_denied_privilege_escalation_role',
          rpc: 'rpc_platform_user_role_upsert_v1',
          params: {
            'p_target_user_id': targetUserId,
            'p_system_key': 'platformAdmin',
            'p_role_key': 'superuser',
            'p_payload': patch,
          },
          expectedDenial: 'Platform admin cannot escalate to superuser role',
        ),
      ];
    case 'superuser':
      return <AttemptSpec>[
        AttemptSpec(
          actor: actor,
          caseKey: 'superuser_denied_self_deactivate',
          rpc: 'rpc_core_admin_user_deactivate_v1',
          params: {'p_target_user_id': selfUserId, 'p_patch': patch},
          expectedDenial:
              'Self-lockout guard denies superuser self deactivation',
        ),
        AttemptSpec(
          actor: actor,
          caseKey: 'superuser_denied_self_superuser_removal',
          rpc: 'rpc_core_admin_user_profile_update_v1',
          params: {
            'p_target_user_id': selfUserId,
            'p_patch': {...patch, 'is_superuser': false},
          },
          expectedDenial: 'Self-lockout guard denies unsafe self-demotion',
        ),
      ];
    default:
      return <AttemptSpec>[];
  }
}

String _asMarkdown(Map<String, dynamic> summary) {
  final buffer = StringBuffer()
    ..writeln(
      '# Platform Development 10H — Actual Negative UAT Evidence Results',
    )
    ..writeln()
    ..writeln('- generated_at_utc: `${summary['generated_at_utc']}`')
    ..writeln('- production_approved: `false`')
    ..writeln(
      '- all_required_actor_cases_denied: `${summary['all_required_actor_cases_denied']}`',
    )
    ..writeln('- unsafe_success_count: `${summary['unsafe_success_count']}`')
    ..writeln('- missing_config_count: `${summary['missing_config_count']}`')
    ..writeln()
    ..writeln('## Actor case status')
    ..writeln()
    ..writeln(
      '| actor | required | denied_attempts | unsafe_success | status |',
    )
    ..writeln('| --- | ---: | ---: | ---: | --- |');
  final actors = summary['actors'] as Map<String, dynamic>;
  for (final entry in actors.entries) {
    final value = entry.value as Map<String, dynamic>;
    buffer.writeln(
      '| ${entry.key} | ${value['required']} | ${value['denied_attempts']} | ${value['unsafe_success']} | ${value['status']} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Notes')
    ..writeln()
    ..writeln(
      '- This evidence was generated using the public anon key and normal user credentials only.',
    )
    ..writeln(
      '- No service_role or elevated server secret is used by this runner.',
    )
    ..writeln(
      '- Any unsafe_success must be treated as a blocker before production approval.',
    );
  return buffer.toString();
}

Future<int> main(List<String> args) async {
  final missing = <String>[];
  final url = _requiredEnv('PWF_SUPABASE_URL', missing);
  final anonKey = _requiredEnv('PWF_SUPABASE_ANON_KEY', missing);
  final targetUserId = _requiredEnv(
    'PWF_NEGATIVE_UAT_TARGET_ADMIN_USER_ID',
    missing,
  );
  final defaultSystemKey =
      _env('PWF_NEGATIVE_UAT_SYSTEM_KEY') ?? 'platformAdmin';
  final outOfScopeSystemKey =
      _env('PWF_NEGATIVE_UAT_OUT_OF_SCOPE_SYSTEM_KEY') ?? defaultSystemKey;
  final roleKey = _env('PWF_NEGATIVE_UAT_ROLE_KEY') ?? 'superuser';
  final permissionKey =
      _env('PWF_NEGATIVE_UAT_PERMISSION_KEY') ?? 'manageUsers';
  final superuserSelfUserId = _requiredEnv(
    'PWF_NEGATIVE_UAT_SUPERUSER_SELF_USER_ID',
    missing,
  );

  final credentials = <String, Map<String, String?>>{
    'unauthorized_authenticated_user': {
      'email': _env('PWF_UAT_UNAUTHORIZED_EMAIL'),
      'password': _env('PWF_UAT_UNAUTHORIZED_PASSWORD'),
    },
    'scoped_user': {
      'email': _env('PWF_UAT_SCOPED_EMAIL'),
      'password': _env('PWF_UAT_SCOPED_PASSWORD'),
    },
    'unit_admin': {
      'email': _env('PWF_UAT_UNIT_ADMIN_EMAIL'),
      'password': _env('PWF_UAT_UNIT_ADMIN_PASSWORD'),
    },
    'platform_admin': {
      'email': _env('PWF_UAT_PLATFORM_ADMIN_EMAIL'),
      'password': _env('PWF_UAT_PLATFORM_ADMIN_PASSWORD'),
    },
    'superuser': {
      'email': _env('PWF_UAT_SUPERUSER_EMAIL'),
      'password': _env('PWF_UAT_SUPERUSER_PASSWORD'),
    },
  };

  for (final entry in credentials.entries) {
    if (entry.value['email'] == null) missing.add('${entry.key}.email');
    if (entry.value['password'] == null) missing.add('${entry.key}.password');
  }

  final outputDir = Directory(
    _env('PWF_NEGATIVE_UAT_OUTPUT_DIR') ??
        'evidence/platform_development_10h_actual_negative_uat/results',
  );
  outputDir.createSync(recursive: true);
  final runId = _timestamp();
  final results = <Map<String, dynamic>>[];

  if (missing.isNotEmpty) {
    final payload = <String, dynamic>{
      'generated_at_utc': DateTime.now().toUtc().toIso8601String(),
      'run_id': runId,
      'status': 'missing_config',
      'missing': missing,
      'production_approved': false,
    };
    File(
      '${outputDir.path}/actual_negative_uat_missing_config_$runId.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
    stderr.writeln('Missing required configuration: ${missing.join(', ')}');
    return 2;
  }

  final anonymous = await _anonymousSession(url, anonKey);
  for (final spec in _anonymousAttempts()) {
    results.add(await _runAttempt(anonymous, spec));
  }

  for (final entry in credentials.entries) {
    final actor = entry.key;
    final email = entry.value['email']!;
    final password = entry.value['password']!;
    final session = await _signedInSession(
      actor: actor,
      url: url,
      anonKey: anonKey,
      email: email,
      password: password,
    );
    final actorSystemKey = actor == 'scoped_user'
        ? outOfScopeSystemKey
        : defaultSystemKey;
    final selfId = actor == 'superuser' ? superuserSelfUserId : targetUserId;
    for (final spec in _actorAttempts(
      actor: actor,
      targetUserId: targetUserId,
      systemKey: actorSystemKey,
      roleKey: roleKey,
      permissionKey: permissionKey,
      selfUserId: selfId,
    )) {
      results.add(await _runAttempt(session, spec));
    }
    await session.client.auth.signOut();
  }

  final requiredActors = <String>[
    'anonymous',
    'unauthorized_authenticated_user',
    'scoped_user',
    'unit_admin',
    'platform_admin',
    'superuser',
  ];
  final actorSummary = <String, Map<String, dynamic>>{};
  var unsafeSuccessCount = 0;
  for (final actor in requiredActors) {
    final actorResults = results.where((r) => r['actor'] == actor).toList();
    final deniedAttempts = actorResults
        .where((r) => r['denied'] == true)
        .length;
    final unsafeSuccess = actorResults
        .where((r) => r['unsafe_success'] == true)
        .length;
    unsafeSuccessCount += unsafeSuccess;
    actorSummary[actor] = <String, dynamic>{
      'required': true,
      'total_attempts': actorResults.length,
      'denied_attempts': deniedAttempts,
      'unsafe_success': unsafeSuccess,
      'status': actorResults.isNotEmpty && unsafeSuccess == 0
          ? 'passed_negative_denial'
          : 'blocked',
    };
  }

  final allRequiredDenied = actorSummary.values.every(
    (v) => v['status'] == 'passed_negative_denial',
  );
  final summary = <String, dynamic>{
    'generated_at_utc': DateTime.now().toUtc().toIso8601String(),
    'run_id': runId,
    'production_approved': false,
    'all_required_actor_cases_denied': allRequiredDenied,
    'unsafe_success_count': unsafeSuccessCount,
    'missing_config_count': 0,
    'actors': actorSummary,
    'covered_rpc_names': _rpcNames,
    'results': results,
  };

  final jsonFile = File(
    '${outputDir.path}/actual_negative_uat_results_$runId.json',
  );
  final mdFile = File(
    '${outputDir.path}/actual_negative_uat_results_$runId.md',
  );
  jsonFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(summary),
  );
  mdFile.writeAsStringSync(_asMarkdown(summary));

  stdout.writeln('Actual Negative UAT evidence written: ${jsonFile.path}');
  stdout.writeln('Markdown summary written: ${mdFile.path}');
  stdout.writeln('all_required_actor_cases_denied=$allRequiredDenied');
  stdout.writeln('unsafe_success_count=$unsafeSuccessCount');
  return allRequiredDenied && unsafeSuccessCount == 0 ? 0 : 1;
}
