import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !serviceRoleKey) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const adminUsersSchema = process.env.ADMIN_USERS_SCHEMA || 'public';
const adminUsersTable = process.env.ADMIN_USERS_TABLE || 'admin_users';
const dryRun = !process.argv.includes('--apply') && process.env.DRY_RUN !== 'false';
const onlyActiveUnits = process.env.ONLY_ACTIVE_UNITS !== 'false';

const ADMIN_ROLE_VALUE = process.env.ADMIN_ROLE_VALUE || 'admin';
const USER_ROLE_VALUE = process.env.USER_ROLE_VALUE || 'user';

const MANUAL_MAP = {
  auth_user_id: process.env.COL_AUTH_USER_ID || 'auth_user_id',
  username: process.env.COL_USERNAME || 'username',
  email: process.env.COL_EMAIL || 'email',
  display_name: process.env.COL_DISPLAY_NAME || 'display_name',
  platform_role: process.env.COL_PLATFORM_ROLE || 'platform_role',
  unit_id: process.env.COL_UNIT_ID || 'unit_id',
  is_active: process.env.COL_IS_ACTIVE || 'is_active',
};

const supabase = createClient(url, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

function buildAccounts(unit) {
  const key = unit.login_key;
  return [
    {
      kind: 'admin',
      username: `${key}admin`,
      password: `${key}123`,
      email: `${key}.admin@palwakf.local`,
      display_name: `${unit.name_ar || unit.slug} - مدير`,
      platform_role: ADMIN_ROLE_VALUE,
    },
    {
      kind: 'usr1',
      username: `${key}usr1`,
      password: `${key}456`,
      email: `${key}.usr1@palwakf.local`,
      display_name: `${unit.name_ar || unit.slug} - مستخدم 1`,
      platform_role: USER_ROLE_VALUE,
    },
    {
      kind: 'usr2',
      username: `${key}usr2`,
      password: `${key}456`,
      email: `${key}.usr2@palwakf.local`,
      display_name: `${unit.name_ar || unit.slug} - مستخدم 2`,
      platform_role: USER_ROLE_VALUE,
    },
  ];
}

async function fetchUnits() {
  let query = supabase.schema('core').from('org_units').select('id, slug, name_ar, login_key, is_active').not('login_key', 'is', null);
  if (onlyActiveUnits) query = query.eq('is_active', true);
  const { data, error } = await query.order('login_key');
  if (error) throw error;
  return (data || []).filter((u) => String(u.login_key || '').trim() !== '');
}

async function detectAdminUsersColumns() {
  // Try to infer from existing row keys.
  const { data, error } = await supabase.schema(adminUsersSchema).from(adminUsersTable).select('*').limit(1);
  if (error) {
    console.warn('[warn] Could not sample admin_users row. Falling back to manual mapping.', error.message);
    return { ...MANUAL_MAP, detected: false };
  }

  if (!data || data.length === 0) {
    console.warn('[warn] admin_users appears empty. Using manual mapping from .env.');
    return { ...MANUAL_MAP, detected: false };
  }

  const keys = Object.keys(data[0]);
  const pick = (...candidates) => candidates.find((c) => keys.includes(c));

  const mapping = {
    auth_user_id: pick(MANUAL_MAP.auth_user_id, 'auth_user_id', 'user_id', 'auth_user_uuid'),
    username: pick(MANUAL_MAP.username, 'username', 'user_name', 'login_name'),
    email: pick(MANUAL_MAP.email, 'email'),
    display_name: pick(MANUAL_MAP.display_name, 'display_name', 'full_name', 'name'),
    platform_role: pick(MANUAL_MAP.platform_role, 'platform_role', 'role'),
    unit_id: pick(MANUAL_MAP.unit_id, 'unit_id', 'org_unit_id'),
    is_active: pick(MANUAL_MAP.is_active, 'is_active', 'active'),
    detected: true,
  };

  console.log('[info] Detected admin_users keys:', keys);
  console.log('[info] Using mapping:', mapping);
  return mapping;
}

async function listAllUsers() {
  const users = [];
  let page = 1;
  const perPage = 1000;

  while (true) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage });
    if (error) throw error;
    const batch = data?.users || [];
    users.push(...batch);
    if (batch.length < perPage) break;
    page += 1;
  }

  return users;
}

async function findExistingAdminUserRow(mapping, value) {
  if (!mapping.auth_user_id || !value) return null;
  const { data, error } = await supabase
    .schema(adminUsersSchema)
    .from(adminUsersTable)
    .select('*')
    .eq(mapping.auth_user_id, value)
    .limit(1)
    .maybeSingle();

  if (error) {
    console.warn('[warn] Could not query existing admin_users by auth id:', error.message);
    return null;
  }
  return data || null;
}

function buildAdminUsersPayload(mapping, account, unit, authUserId) {
  const payload = {};
  if (mapping.auth_user_id) payload[mapping.auth_user_id] = authUserId;
  if (mapping.username) payload[mapping.username] = account.username;
  if (mapping.email) payload[mapping.email] = account.email;
  if (mapping.display_name) payload[mapping.display_name] = account.display_name;
  if (mapping.platform_role) payload[mapping.platform_role] = account.platform_role;
  if (mapping.unit_id) payload[mapping.unit_id] = unit.id;
  if (mapping.is_active) payload[mapping.is_active] = true;
  return payload;
}

async function ensureAuthUser(existingUsersByEmail, account, unit) {
  const existing = existingUsersByEmail.get(account.email.toLowerCase());
  if (existing) return existing.id;

  if (dryRun) {
    console.log(`[dry-run] CREATE AUTH ${account.username} <${account.email}>`);
    return `dry-run-${account.username}`;
  }

  const { data, error } = await supabase.auth.admin.createUser({
    email: account.email,
    password: account.password,
    email_confirm: true,
    user_metadata: {
      username: account.username,
      login_key: unit.login_key,
      unit_id: unit.id,
      unit_slug: unit.slug,
      unit_name_ar: unit.name_ar,
      seed_kind: account.kind,
      platform_role: account.platform_role,
    },
  });

  if (error) throw error;
  if (!data.user?.id) throw new Error(`No auth user id returned for ${account.username}`);
  existingUsersByEmail.set(account.email.toLowerCase(), data.user);
  return data.user.id;
}

async function syncAdminUser(mapping, payload, authUserId) {
  if (dryRun) {
    console.log('[dry-run] UPSERT admin_users payload:', payload);
    return;
  }

  const existing = await findExistingAdminUserRow(mapping, authUserId);

  if (existing) {
    const { error } = await supabase
      .schema(adminUsersSchema)
      .from(adminUsersTable)
      .update(payload)
      .eq(mapping.auth_user_id, authUserId);

    if (error) throw error;
    return;
  }

  const { error } = await supabase
    .schema(adminUsersSchema)
    .from(adminUsersTable)
    .insert(payload);

  if (error) throw error;
}

async function main() {
  console.log('[info] Mode:', dryRun ? 'DRY RUN' : 'APPLY');
  console.log('[info] admin_users target:', `${adminUsersSchema}.${adminUsersTable}`);

  const units = await fetchUnits();
  console.log(`[info] Units to process: ${units.length}`);

  const mapping = await detectAdminUsersColumns();
  if (!mapping.auth_user_id) {
    throw new Error('Could not determine auth user id column in admin_users. Set COL_AUTH_USER_ID in .env.');
  }

  const existingUsers = await listAllUsers();
  const usersByEmail = new Map(existingUsers.filter(Boolean).map((u) => [String(u.email || '').toLowerCase(), u]));
  console.log(`[info] Existing auth users loaded: ${existingUsers.length}`);

  for (const unit of units) {
    const accounts = buildAccounts(unit);
    console.log(`\n[unit] ${unit.login_key} / ${unit.slug}`);

    for (const account of accounts) {
      try {
        const authUserId = await ensureAuthUser(usersByEmail, account, unit);
        const payload = buildAdminUsersPayload(mapping, account, unit, authUserId);
        await syncAdminUser(mapping, payload, authUserId);
        console.log(`[ok] ${account.username}`);
      } catch (err) {
        console.error(`[failed] ${account.username}:`, err.message || err);
      }
    }
  }

  console.log('\n[done] Seed process finished.');
}

main().catch((err) => {
  console.error('[fatal]', err.message || err);
  process.exit(1);
});
