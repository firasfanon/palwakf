-- PalWakf Hotfix (V3) — Fix limited org units list + Chatbot tables schema
-- Date: 2026-03-01
--
-- Goals:
-- 1) Ensure public.org_units (and public.org_unit_profiles if present) contains ALL rows from core.* (common columns only).
--    This fixes dropdowns showing only (home,bth,jer) when the app reads from public.org_units.
-- 2) Ensure chatbot tables exist with required columns (unit_id + admin_user_id) matching PwfChatbotRepository.

begin;

-- ---------- (A) Sync org units from core -> public (common columns only) ----------
do $$
declare
  cols text;
  upd  text;
  q    text;
begin
  if to_regclass('core.org_units') is null then
    raise exception 'Missing core.org_units (expected in PalWakf DB).';
  end if;

  -- Ensure public.org_units exists (create minimal clone if missing)
  if to_regclass('public.org_units') is null then
    execute 'create table public.org_units (like core.org_units including all)';
  end if;

  -- Build common-column list between core.org_units and public.org_units
  select string_agg(format('%I', p.column_name), ',')
    into cols
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_units'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_units' and c.column_name=p.column_name
    );

  if cols is null or cols = '' then
    raise exception 'No common columns between core.org_units and public.org_units.';
  end if;

  -- Build update-set for common columns (exclude primary key)
  select string_agg(format('%I = excluded.%I', p.column_name, p.column_name), ',')
    into upd
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_units'
    and p.column_name <> 'id'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_units' and c.column_name=p.column_name
    );

  q := format(
    'insert into public.org_units (%s) select %s from core.org_units on conflict (id) do update set %s',
    cols, cols, upd
  );
  execute q;
end $$;

-- Optional: sync profiles if BOTH exist (common columns only).
do $$
declare
  cols text;
  upd  text;
  q    text;
begin
  if to_regclass('core.org_unit_profiles') is null then
    -- core profiles not present in this DB; skip safely.
    return;
  end if;

  -- Ensure public.org_unit_profiles exists (clone if missing)
  if to_regclass('public.org_unit_profiles') is null then
    execute 'create table public.org_unit_profiles (like core.org_unit_profiles including all)';
  end if;

  select string_agg(format('%I', p.column_name), ',')
    into cols
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_unit_profiles'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_unit_profiles' and c.column_name=p.column_name
    );

  if cols is null or cols = '' then
    raise exception 'No common columns between core.org_unit_profiles and public.org_unit_profiles.';
  end if;

  select string_agg(format('%I = excluded.%I', p.column_name, p.column_name), ',')
    into upd
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_unit_profiles'
    and p.column_name <> 'unit_id'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_unit_profiles' and c.column_name=p.column_name
    );

  q := format(
    'insert into public.org_unit_profiles (%s) select %s from core.org_unit_profiles on conflict (unit_id) do update set %s',
    cols, cols, upd
  );
  execute q;
exception
  when undefined_table then
    -- If public.org_unit_profiles has no unique/PK on unit_id yet, skip and let you add later.
    return;
end $$;

-- ---------- (B) Chatbot tables schema (required by features/chatbot) ----------
create extension if not exists pgcrypto;

create table if not exists public.chatbot_conversations (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references core.org_units(id) on delete cascade,
  admin_user_id uuid not null references public.admin_users(id) on delete cascade,
  title text,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chatbot_messages (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references core.org_units(id) on delete cascade,
  conversation_id uuid not null references public.chatbot_conversations(id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null,
  created_at timestamptz not null default now()
);

-- If tables existed with missing columns, ensure required columns exist
alter table public.chatbot_conversations
  add column if not exists unit_id uuid,
  add column if not exists admin_user_id uuid,
  add column if not exists title text,
  add column if not exists last_message_at timestamptz,
  add column if not exists created_at timestamptz,
  add column if not exists updated_at timestamptz;

alter table public.chatbot_messages
  add column if not exists unit_id uuid,
  add column if not exists conversation_id uuid,
  add column if not exists role text,
  add column if not exists content text,
  add column if not exists created_at timestamptz;

create index if not exists chatbot_conversations_admin_idx on public.chatbot_conversations(admin_user_id, last_message_at desc nulls last);
create index if not exists chatbot_messages_conv_time_idx on public.chatbot_messages(conversation_id, created_at asc);

-- Trigger: bump conversation timestamps when inserting messages
create or replace function public.pwf_chatbot_bump_conversation()
returns trigger
language plpgsql
as $$
begin
  update public.chatbot_conversations
    set last_message_at = new.created_at,
        updated_at = now()
  where id = new.conversation_id;
  return new;
end $$;

drop trigger if exists pwf_chatbot_bump_conversation_trg on public.chatbot_messages;
create trigger pwf_chatbot_bump_conversation_trg
after insert on public.chatbot_messages
for each row execute function public.pwf_chatbot_bump_conversation();

-- RLS
alter table public.chatbot_conversations enable row level security;
alter table public.chatbot_messages enable row level security;

drop policy if exists "chatbot_conversations_select_own" on public.chatbot_conversations;
create policy "chatbot_conversations_select_own"
on public.chatbot_conversations for select
using (admin_user_id = auth.uid());

drop policy if exists "chatbot_conversations_insert_own" on public.chatbot_conversations;
create policy "chatbot_conversations_insert_own"
on public.chatbot_conversations for insert
with check (admin_user_id = auth.uid());

drop policy if exists "chatbot_conversations_update_own" on public.chatbot_conversations;
create policy "chatbot_conversations_update_own"
on public.chatbot_conversations for update
using (admin_user_id = auth.uid())
with check (admin_user_id = auth.uid());

drop policy if exists "chatbot_conversations_delete_own" on public.chatbot_conversations;
create policy "chatbot_conversations_delete_own"
on public.chatbot_conversations for delete
using (admin_user_id = auth.uid());

drop policy if exists "chatbot_messages_select_own" on public.chatbot_messages;
create policy "chatbot_messages_select_own"
on public.chatbot_messages for select
using (
  exists (
    select 1
    from public.chatbot_conversations c
    where c.id = chatbot_messages.conversation_id
      and c.admin_user_id = auth.uid()
  )
);

drop policy if exists "chatbot_messages_insert_own" on public.chatbot_messages;
create policy "chatbot_messages_insert_own"
on public.chatbot_messages for insert
with check (
  exists (
    select 1
    from public.chatbot_conversations c
    where c.id = chatbot_messages.conversation_id
      and c.admin_user_id = auth.uid()
      and c.unit_id = chatbot_messages.unit_id
  )
);

commit;