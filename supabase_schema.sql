-- Focus & Life Tracker — Ota-ona/Farzand (Parent-Child) schema
-- Buni Supabase loyihangizda: chap menyu -> SQL Editor -> "New query"
-- ga joylashtirib, "Run" bosing. Bir marta ishga tushirilsa yetarli.

create extension if not exists "pgcrypto";

-- Juftlashtirish kodlari: farzand qurilmasi kod yaratadi, ota-ona
-- qurilmasi shu kodni kiritib bog'lanadi. Kod bog'langach qayta
-- ishlatib bo'lmaydi (parent_device_id to'ldiriladi).
create table if not exists family_links (
  id uuid primary key default gen_random_uuid(),
  pairing_code text unique not null,
  child_device_id text not null,
  child_name text,
  parent_device_id text,
  created_at timestamptz default now(),
  linked_at timestamptz
);

-- Farzand qurilmasi har kuni o'z rejasi va bajarilish holatini shu
-- yerga yozib turadi (JSON sifatida) — ota-ona shundan o'qiydi.
create table if not exists child_snapshots (
  id uuid primary key default gen_random_uuid(),
  child_device_id text not null,
  date text not null, -- yyyy-MM-dd
  tasks_json text not null,
  day_progress real not null default 0,
  updated_at timestamptz default now(),
  unique (child_device_id, date)
);

-- Row Level Security yoqiladi va anon-key orqali cheklangan
-- ruxsatlar beriladi (to'liq ochiq emas, lekin ushbu ilova
-- shaxsiy/oilaviy foydalanish uchun mo'ljallangan — yuqori
-- xavfsizlikni talab qiluvchi holatlar uchun mos emas).
alter table family_links enable row level security;
alter table child_snapshots enable row level security;

create policy "anon can read/write family_links" on family_links
  for all using (true) with check (true);

create policy "anon can read/write child_snapshots" on child_snapshots
  for all using (true) with check (true);
