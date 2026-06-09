-- PalWakf — Hotfix: Chatbot schema for /admin/chatbot
begin;

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

create index if not exists chatbot_conversations_admin_idx
  on public.chatbot_conversations(admin_user_id, last_message_at desc nulls last);

create index if not exists chatbot_messages_conv_time_idx
  on public.chatbot_messages(conversation_id, created_at asc);

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