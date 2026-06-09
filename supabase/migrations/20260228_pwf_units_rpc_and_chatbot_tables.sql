-- PalWakf Patch: Admin Units RPC + Chatbot Tables (public) + RLS
-- Purpose:
-- 1) Provide stable RPCs (public schema) to read org units from core.org_units/core.org_unit_profiles
--    even if the client cannot access `core` schema directly.
-- 2) Create chatbot tables required by /admin/chatbot (chatbot_conversations / chatbot_messages).

-- =========================
-- 0) Helper: Resolve unit id by slug (ensure it reads from core.org_units)
-- =========================
create or replace function public.pwf_resolve_unit_id(p_unit_slug text)
returns uuid
language plpgsql
security definer
as $$
declare
  v uuid;
begin
  select u.id into v
  from core.org_units u
  where lower(coalesce(u.slug, '')) = lower(trim(p_unit_slug))
  limit 1;

  return v;
end;
$$;

grant execute on function public.pwf_resolve_unit_id(text) to authenticated;

-- =========================
-- 1) RPC: list units with embedded profiles (shape compatible with PostgREST embed)
-- =========================
create or replace function public.pwf_list_units_with_profiles(p_only_active boolean default true)
returns table(
  id uuid,
  unit_type text,
  parent_id uuid,
  governorate_id uuid,
  code text,
  slug text,
  name_ar text,
  name_en text,
  is_active boolean,
  sort_order integer,
  created_at timestamptz,
  updated_at timestamptz,
  org_unit_profiles jsonb
)
language sql
security definer
as $$
  select
    u.id,
    u.unit_type::text as unit_type,
    u.parent_id,
    u.governorate_id,
    u.code,
    u.slug,
    u.name_ar,
    u.name_en,
    u.is_active,
    u.sort_order,
    u.created_at,
    u.updated_at,
    case
      when p.unit_id is null then '[]'::jsonb
      else jsonb_build_array(to_jsonb(p))
    end as org_unit_profiles
  from core.org_units u
  left join core.org_unit_profiles p on p.unit_id = u.id
  where (not p_only_active) or u.is_active = true
  order by u.sort_order nulls last, u.name_ar;
$$;

grant execute on function public.pwf_list_units_with_profiles(boolean) to authenticated;

-- =========================
-- 2) RPC: get single unit by slug with embedded profile
-- =========================
create or replace function public.pwf_get_unit_with_profile_by_slug(p_slug text)
returns table(
  id uuid,
  unit_type text,
  parent_id uuid,
  governorate_id uuid,
  code text,
  slug text,
  name_ar text,
  name_en text,
  is_active boolean,
  sort_order integer,
  created_at timestamptz,
  updated_at timestamptz,
  org_unit_profiles jsonb
)
language sql
security definer
as $$
  select
    u.id,
    u.unit_type::text as unit_type,
    u.parent_id,
    u.governorate_id,
    u.code,
    u.slug,
    u.name_ar,
    u.name_en,
    u.is_active,
    u.sort_order,
    u.created_at,
    u.updated_at,
    case
      when p.unit_id is null then '[]'::jsonb
      else jsonb_build_array(to_jsonb(p))
    end as org_unit_profiles
  from core.org_units u
  left join core.org_unit_profiles p on p.unit_id = u.id
  where lower(coalesce(u.slug,'')) = lower(trim(p_slug))
  limit 1;
$$;

grant execute on function public.pwf_get_unit_with_profile_by_slug(text) to authenticated;

-- =========================
-- 3) RPC: get org unit profile by unit_id
-- =========================
create or replace function public.pwf_get_org_unit_profile(p_unit_id uuid)
returns jsonb
language sql
security definer
as $$
  select to_jsonb(p)
  from core.org_unit_profiles p
  where p.unit_id = p_unit_id
  limit 1;
$$;

grant execute on function public.pwf_get_org_unit_profile(uuid) to authenticated;

-- =========================
-- 4) Chatbot tables (public) required by feature/chatbot repository
-- =========================
create table if not exists public.chatbot_conversations (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references core.org_units(id) on delete restrict,
  admin_user_id uuid not null references auth.users(id) on delete cascade,
  title text null,
  last_message_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists chatbot_conversations_unit_admin_idx
on public.chatbot_conversations (unit_id, admin_user_id, last_message_at desc);

create table if not exists public.chatbot_messages (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references core.org_units(id) on delete restrict,
  conversation_id uuid not null references public.chatbot_conversations(id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists chatbot_messages_conv_created_idx
on public.chatbot_messages (conversation_id, created_at asc);

create index if not exists chatbot_messages_unit_created_idx
on public.chatbot_messages (unit_id, created_at desc);

-- Touch conversation on new message
create or replace function public.pwf_chatbot_touch_conversation()
returns trigger
language plpgsql
as $$
begin
  update public.chatbot_conversations
     set last_message_at = now()
   where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists pwf_chatbot_touch_conversation_trg on public.chatbot_messages;
create trigger pwf_chatbot_touch_conversation_trg
after insert on public.chatbot_messages
for each row execute function public.pwf_chatbot_touch_conversation();

-- =========================
-- 5) RLS (Owner-based): only allow the authenticated admin to access their conversations/messages
-- =========================
alter table public.chatbot_conversations enable row level security;
alter table public.chatbot_messages enable row level security;

drop policy if exists chatbot_conversations_own on public.chatbot_conversations;
create policy chatbot_conversations_own
on public.chatbot_conversations
for all
using (admin_user_id = auth.uid())
with check (admin_user_id = auth.uid());

drop policy if exists chatbot_messages_own on public.chatbot_messages;
create policy chatbot_messages_own
on public.chatbot_messages
for all
using (
  exists (
    select 1
    from public.chatbot_conversations c
    where c.id = conversation_id
      and c.admin_user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.chatbot_conversations c
    where c.id = conversation_id
      and c.admin_user_id = auth.uid()
  )
);
