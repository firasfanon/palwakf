import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SEED_MODE = (process.env.SEED_MODE || 'dry').toLowerCase();
const ONLY_SELECTED = (process.env.ONLY_SELECTED || 'false').toLowerCase() === 'true';
const SELECTED_LOGIN_KEYS = (process.env.SELECTED_LOGIN_KEYS || '')
  .split(',')
  .map((v) => v.trim())
  .filter(Boolean);
const EMAIL_DOMAIN = process.env.EMAIL_DOMAIN || 'palwakf.local';
const DEPARTMENT_MODE = process.env.DEPARTMENT_MODE || 'slug';
const NAME_MODE = process.env.NAME_MODE || 'username';
const EMAIL_CONFIRM = (process.env.EMAIL_CONFIRM || 'true').toLowerCase() === 'true';
const USER_ROLE = (process.env.USER_ROLE || 'employee').toLowerCase();

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false }
});

function buildAccounts(unit) {
  const user1Username = `${unit.login_key}usr1`;
  const user2Username = `${unit.login_key}usr2`;

  return [
    {
      username: user1Username,
      email: `${user1Username}@${EMAIL_DOMAIN}`,
      password: `${unit.login_key}456`,
      role: USER_ROLE,
      displayRoleAr: 'مستخدم الوحدة 1'
    },
    {
      username: user2Username,
      email: `${user2Username}@${EMAIL_DOMAIN}`,
      password: `${unit.login_key}456`,
      role: USER_ROLE,
      displayRoleAr: 'مستخدم الوحدة 2'
    }
  ];
}

function resolveDepartment(unit) {
  if (DEPARTMENT_MODE === 'name_ar') return unit.name_ar || unit.slug;
  if (DEPARTMENT_MODE === 'login_key') return unit.login_key;
  return unit.slug;
}

function resolveName(unit, account) {
  if (NAME_MODE === 'display') {
    return `${unit.name_ar || unit.slug} - ${account.displayRoleAr}`;
  }
  return account.username;
}

async function listUnits() {
  let query = supabase
    .schema('core')
    .from('org_units')
    .select('id, slug, name_ar, login_key, is_active')
    .eq('is_active', true)
    .not('login_key', 'is', null)
    .order('login_key');

  if (ONLY_SELECTED && SELECTED_LOGIN_KEYS.length > 0) {
    query = query.in('login_key', SELECTED_LOGIN_KEYS);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
}

async function listAllAuthUsers() {
  const all = [];
  let page = 1;
  const perPage = 1000;

  while (true) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage });
    if (error) throw error;

    const users = data?.users || [];
    all.push(...users);

    if (users.length < perPage) break;
    page += 1;
  }

  return all;
}

function buildAuthUserMap(users) {
  const map = new Map();
  for (const user of users) {
    const email = (user.email || '').toLowerCase().trim();
    if (email) map.set(email, user);
  }
  return map;
}

async function createAuthUser(account, unit) {
  const { data, error } = await supabase.auth.admin.createUser({
    email: account.email,
    password: account.password,
    email_confirm: EMAIL_CONFIRM,
    user_metadata: {
      username: account.username,
      login_key: unit.login_key,
      unit_id: unit.id,
      unit_slug: unit.slug,
      unit_name_ar: unit.name_ar,
      seeded: true,
      seeded_type: 'unit_admin_account',
      platform_role: account.role
    }
  });

  if (error) throw error;
  return data.user;
}

async function upsertAdminUser(authUser, unit, account) {
  const payload = {
    id: authUser.id,
    email: account.email,
    username: account.username,
    name: resolveName(unit, account),
    role: account.role,
    department: resolveDepartment(unit),
    governorate: null,
    phone: null,
    avatar_url: null,
    is_active: true,
    directorate_id: null,
    is_superuser: false,
    unit_id: unit.id,
    updated_at: new Date().toISOString()
  };

  const { error } = await supabase
    .schema('public')
    .from('admin_users')
    .upsert(payload, { onConflict: 'id' });

  if (error) throw error;
}

async function main() {
  const units = await listUnits();
  console.log(`[seed] mode=${SEED_MODE} units=${units.length}`);

  let authUserMap = new Map();
  if (SEED_MODE !== 'dry') {
    const authUsers = await listAllAuthUsers();
    authUserMap = buildAuthUserMap(authUsers);
    console.log(`[seed] existing_auth_users=${authUsers.length}`);
  }

  for (const unit of units) {
    const accounts = buildAccounts(unit);

    for (const account of accounts) {
      try {
        const existing = SEED_MODE === 'dry'
          ? null
          : authUserMap.get(account.email.toLowerCase()) || null;

        if (SEED_MODE === 'dry') {
          console.log(JSON.stringify({
            action: existing ? 'would-upsert-admin-user' : 'would-create-auth-and-admin-user',
            unit: unit.slug,
            login_key: unit.login_key,
            username: account.username,
            email: account.email,
            role: account.role,
            unit_id: unit.id,
            existing_auth_id: existing?.id || null
          }));
          continue;
        }

        const authUser = existing || await createAuthUser(account, unit);
        if (!existing) {
          authUserMap.set(account.email.toLowerCase(), authUser);
        }
        await upsertAdminUser(authUser, unit, account);

        console.log(JSON.stringify({
          action: existing ? 'upserted-admin-user' : 'created-auth-and-admin-user',
          unit: unit.slug,
          login_key: unit.login_key,
          username: account.username,
          email: account.email,
          role: account.role,
          unit_id: unit.id,
          auth_id: authUser.id
        }));
      } catch (error) {
        console.error(JSON.stringify({
          action: 'failed',
          unit: unit.slug,
          login_key: unit.login_key,
          username: account.username,
          email: account.email,
          error: error?.message || String(error)
        }));
      }
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
