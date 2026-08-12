-- Focus & Life Tracker — Project Manager schema
-- Supabase loyihangizda: SQL Editor -> New query -> shu matnni joylashtiring -> Run.

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  owner_device_id text not null,
  invite_code text unique not null,
  deadline timestamptz,
  created_at timestamptz default now()
);

create table if not exists project_members (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  device_id text not null,
  member_name text not null,
  role text not null default 'member', -- 'owner' | 'member'
  joined_at timestamptz default now(),
  unique (project_id, device_id)
);

create table if not exists project_tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'todo', -- 'todo' | 'in_progress' | 'done'
  priority text not null default 'normal', -- 'low' | 'normal' | 'high'
  assigned_to text, -- device_id, nullable
  deadline timestamptz,
  order_index integer not null default 0,
  created_by text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table projects enable row level security;
alter table project_members enable row level security;
alter table project_tasks enable row level security;

create policy "anon can read/write projects" on projects for all using (true) with check (true);
create policy "anon can read/write project_members" on project_members for all using (true) with check (true);
create policy "anon can read/write project_tasks" on project_tasks for all using (true) with check (true);
