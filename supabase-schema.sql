create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  role text not null default 'editor' check (role in ('admin', 'editor')),
  created_at timestamptz not null default now()
);

create table if not exists public.memories (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  titulo text not null,
  texto text not null,
  img text,
  mood text,
  created_at timestamptz not null default now()
);

create table if not exists public.moods (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  mood text not null check (mood in ('😊', '❤️', '🥹', '😌', '💪')),
  created_at timestamptz not null default now()
);

create table if not exists public.activity (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  user_email text,
  action text not null,
  created_at timestamptz not null default now()
);

alter table public.memories
  add column if not exists img text,
  add column if not exists mood text;
alter table public.moods
  add column if not exists user_id uuid references auth.users (id) on delete cascade,
  add column if not exists created_at timestamptz not null default now();
alter table public.activity
  add column if not exists user_id uuid references auth.users (id) on delete cascade;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'admin'
  );
$$;

create or replace function public.create_profile_for_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'editor')
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists create_profile_after_signup on auth.users;
create trigger create_profile_after_signup
  after insert on auth.users
  for each row execute procedure public.create_profile_for_auth_user();

create index if not exists memories_user_created_idx
  on public.memories (user_id, created_at desc);
create index if not exists moods_user_created_idx
  on public.moods (user_id, created_at desc);
create index if not exists activity_created_idx
  on public.activity (created_at desc);

alter table public.profiles enable row level security;
alter table public.memories enable row level security;
alter table public.moods enable row level security;
alter table public.activity enable row level security;

drop policy if exists "Users can read own profile and admins can read all" on public.profiles;
create policy "Users can read own profile and admins can read all"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select public.is_admin()));

drop policy if exists "Authenticated users can read memories" on public.memories;
create policy "Authenticated users can read memories"
  on public.memories for select to authenticated
  using (exists (select 1 from public.profiles where id = (select auth.uid())));

drop policy if exists "Editors can create memories" on public.memories;
create policy "Editors can create memories"
  on public.memories for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role in ('admin', 'editor')
    )
  );

drop policy if exists "Owners and admins can update memories" on public.memories;
create policy "Owners and admins can update memories"
  on public.memories for update to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()))
  with check (user_id = (select auth.uid()) or (select public.is_admin()));

drop policy if exists "Owners and admins can delete memories" on public.memories;
create policy "Owners and admins can delete memories"
  on public.memories for delete to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));

drop policy if exists "Users can read moods" on public.moods;
create policy "Users can read moods"
  on public.moods for select to authenticated
  using (exists (select 1 from public.profiles where id = (select auth.uid())));

drop policy if exists "Users can add own moods" on public.moods;
create policy "Users can add own moods"
  on public.moods for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.profiles where id = (select auth.uid()))
  );

drop policy if exists "Admins can read activity" on public.activity;
create policy "Admins can read activity"
  on public.activity for select to authenticated
  using ((select public.is_admin()));

drop policy if exists "Users can log own activity" on public.activity;
create policy "Users can log own activity"
  on public.activity for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.profiles where id = (select auth.uid()))
  );

do $$
begin
  alter publication supabase_realtime add table public.memories;
exception
  when duplicate_object then null;
  when undefined_object then null;
end;
$$;

-- After creating the first account, grant the initial administrator role:
-- update public.profiles set role = 'admin' where email = 'admin@example.com';
update public.profiles
set role = 'admin'
where email = 'luciacampos3068@gmail.com';

create table profiles (

id uuid primary key,

email text,

role text default 'editor'

);

create table memories (

id bigint generated always
as identity primary key,

user_id uuid,

titulo text,

texto text,

created_at timestamp
default now()

);

create table letters (

id bigint generated always as identity primary key,

titulo text,

conteudo text,

created_at timestamp default now()

);

create table capsules (

id bigint generated always as identity primary key,

open_date date,

content text,

created_at timestamp default now()

);

create table moods (

id bigint generated always as identity primary key,

memory_id bigint,

emotion text,

created_at timestamp default now()

);

create table favorites (

id bigint generated always as identity primary key,

memory_id bigint,

user_id uuid,

created_at timestamp default now()

);

create table activities (

id bigint generated always as identity primary key,

user_email text,

action text,

created_at timestamp default now()

);

create table comments (

id bigint generated always as identity primary key,

memory_id bigint,

user_id uuid,

content text,

created_at timestamp default now()

);

create table reactions (

id bigint generated always as identity primary key,

memory_id bigint,

user_id uuid,

reaction text,

created_at timestamp default now()

);

create table invitations (

id bigint generated always as identity primary key,

email text,

role text,

status text default 'pending',

created_at timestamp default now()

);

