-- Brain Fog Tracker v3 - Supabase schema
-- Run this once in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  sleep_hours numeric(4,1),
  sleep_quality smallint check (sleep_quality between 0 and 10),
  night_wake smallint check (night_wake >= 0),
  night_urine smallint check (night_urine >= 0),
  morning_fog smallint check (morning_fog between 0 and 10),
  morning_energy smallint check (morning_energy between 0 and 10),
  magnesium boolean,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, log_date)
);

create table if not exists public.measurements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  fog smallint check (fog between 0 and 10),
  glucose numeric(6,1),
  thirst smallint check (thirst between 0 and 10),
  energy smallint check (energy between 0 and 10),
  context text,
  hypo_symptoms boolean,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  meal_type text,
  portion_size text,
  food text,
  carb_level text,
  sugary boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.drinks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  drink_type text,
  ml integer check (ml >= 0),
  caffeine boolean,
  sugary boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.urinations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  amount text,
  color text,
  urgency boolean,
  night boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.naps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  before_fog smallint check (before_fog between 0 and 10),
  minutes integer check (minutes > 0 and minutes <= 240),
  after_fog smallint check (after_fog between 0 and 10),
  energy_after smallint check (energy_after between 0 and 10),
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  local_date date not null,
  exercise_type text,
  minutes integer check (minutes > 0),
  intensity smallint check (intensity between 1 and 10),
  fog_after smallint check (fog_after between 0 and 10),
  created_at timestamptz not null default now()
);

-- Helpful indexes
create index if not exists idx_daily_logs_user_date on public.daily_logs(user_id, log_date desc);
create index if not exists idx_measurements_user_time on public.measurements(user_id, occurred_at desc);
create index if not exists idx_meals_user_time on public.meals(user_id, occurred_at desc);
create index if not exists idx_drinks_user_time on public.drinks(user_id, occurred_at desc);
create index if not exists idx_urinations_user_time on public.urinations(user_id, occurred_at desc);
create index if not exists idx_naps_user_time on public.naps(user_id, occurred_at desc);
create index if not exists idx_exercises_user_time on public.exercises(user_id, occurred_at desc);

-- RLS
alter table public.daily_logs enable row level security;
alter table public.measurements enable row level security;
alter table public.meals enable row level security;
alter table public.drinks enable row level security;
alter table public.urinations enable row level security;
alter table public.naps enable row level security;
alter table public.exercises enable row level security;

-- Own-row policies
drop policy if exists "daily_select_own" on public.daily_logs;
drop policy if exists "daily_insert_own" on public.daily_logs;
drop policy if exists "daily_update_own" on public.daily_logs;
drop policy if exists "daily_delete_own" on public.daily_logs;
create policy "daily_select_own" on public.daily_logs for select to authenticated using (auth.uid() = user_id);
create policy "daily_insert_own" on public.daily_logs for insert to authenticated with check (auth.uid() = user_id);
create policy "daily_update_own" on public.daily_logs for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "daily_delete_own" on public.daily_logs for delete to authenticated using (auth.uid() = user_id);

do $$
declare t text;
begin
  foreach t in array array['measurements','meals','drinks','urinations','naps','exercises']
  loop
    execute format('drop policy if exists "%s_select_own" on public.%I', t, t);
    execute format('drop policy if exists "%s_insert_own" on public.%I', t, t);
    execute format('drop policy if exists "%s_update_own" on public.%I', t, t);
    execute format('drop policy if exists "%s_delete_own" on public.%I', t, t);

    execute format('create policy "%s_select_own" on public.%I for select to authenticated using (auth.uid() = user_id)', t, t);
    execute format('create policy "%s_insert_own" on public.%I for insert to authenticated with check (auth.uid() = user_id)', t, t);
    execute format('create policy "%s_update_own" on public.%I for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id)', t, t);
    execute format('create policy "%s_delete_own" on public.%I for delete to authenticated using (auth.uid() = user_id)', t, t);
  end loop;
end $$;

grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.daily_logs,
  public.measurements,
  public.meals,
  public.drinks,
  public.urinations,
  public.naps,
  public.exercises
to authenticated;
