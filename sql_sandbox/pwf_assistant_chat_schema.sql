-- PalWakf Assistant Chat Schema (INTERNAL assistant persistence)
-- Safe-by-default: stores conversations only for authenticated admin_users.

-- Extensions (Supabase عادةً تملك pgcrypto / uuid-ossp؛ نستخدم pgcrypto للـ gen_random_uuid)
create extension if not exists pgcrypto;

-- 1) Conversations
create table if not exists public.assistant_conversations (
  id uuid primary key default gen_random_uuid(),
  scope_key text not null unique,
  mode text not null,
  unit_id text not null,
  admin_user_id uuid null,
  public_session_id text null,
  system_key text null,
  title text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- FK to admin_users (identity source)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'assistant_conversations_admin_user_fk'
  ) THEN
    ALTER TABLE public.assistant_conversations
      ADD CONSTRAINT assistant_conversations_admin_user_fk
      FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id) ON DELETE SET NULL;
  END IF;
END $$;

create index if not exists idx_assistant_conversations_admin_user on public.assistant_conversations(admin_user_id);
create index if not exists idx_assistant_conversations_system_key on public.assistant_conversations(system_key);

-- 2) Messages
create table if not exists public.assistant_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.assistant_conversations(id) on delete cascade,
  role text not null,
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_assistant_messages_conversation on public.assistant_messages(conversation_id, created_at);

-- 3) updated_at trigger (lightweight)
create or replace function public.pwf_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  NEW.updated_at = now();
  return NEW;
end;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_assistant_conversations_touch'
  ) THEN
    CREATE TRIGGER trg_assistant_conversations_touch
    BEFORE UPDATE ON public.assistant_conversations
    FOR EACH ROW EXECUTE FUNCTION public.pwf_touch_updated_at();
  END IF;
END $$;

-- 4) RLS
alter table public.assistant_conversations enable row level security;
alter table public.assistant_messages enable row level security;

-- Helper: minimal admin check without touching user_system_permissions (avoids recursion)
create or replace function public.pwf_is_active_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
      and au.is_active = true
  );
$$;

-- Conversations: only the owning admin user
drop policy if exists assistant_conversations_admin_select on public.assistant_conversations;
drop policy if exists assistant_conversations_admin_insert on public.assistant_conversations;
drop policy if exists assistant_conversations_admin_update on public.assistant_conversations;
drop policy if exists assistant_conversations_admin_delete on public.assistant_conversations;

create policy assistant_conversations_admin_select
on public.assistant_conversations
for select
using (
  public.pwf_is_active_admin_user()
  and admin_user_id = auth.uid()
);

create policy assistant_conversations_admin_insert
on public.assistant_conversations
for insert
with check (
  public.pwf_is_active_admin_user()
  and admin_user_id = auth.uid()
);

create policy assistant_conversations_admin_update
on public.assistant_conversations
for update
using (
  public.pwf_is_active_admin_user()
  and admin_user_id = auth.uid()
)
with check (
  public.pwf_is_active_admin_user()
  and admin_user_id = auth.uid()
);

create policy assistant_conversations_admin_delete
on public.assistant_conversations
for delete
using (
  public.pwf_is_active_admin_user()
  and admin_user_id = auth.uid()
);

-- Messages: read/write only if the conversation belongs to the admin user
drop policy if exists assistant_messages_admin_select on public.assistant_messages;
drop policy if exists assistant_messages_admin_insert on public.assistant_messages;

create policy assistant_messages_admin_select
on public.assistant_messages
for select
using (
  public.pwf_is_active_admin_user()
  and exists (
    select 1
    from public.assistant_conversations c
    where c.id = assistant_messages.conversation_id
      and c.admin_user_id = auth.uid()
  )
);

create policy assistant_messages_admin_insert
on public.assistant_messages
for insert
with check (
  public.pwf_is_active_admin_user()
  and exists (
    select 1
    from public.assistant_conversations c
    where c.id = assistant_messages.conversation_id
      and c.admin_user_id = auth.uid()
  )
);
