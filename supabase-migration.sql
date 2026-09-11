-- Run this once in the Supabase SQL editor (Dashboard -> SQL Editor -> New query).
-- Idempotent: safe to run multiple times.
--
-- Adds the columns the app writes to monthly_sessions that older schemas lack.
-- Without them the app still saves (it drops missing fields and tells you in
-- the save status), but projection snapshots and partial-month info are lost.

alter table monthly_sessions add column if not exists projection    jsonb;
alter table monthly_sessions add column if not exists days_elapsed  integer;
alter table monthly_sessions add column if not exists days_in_month integer;

-- Shared per-household config (e.g. the GitHub rules token), so the second
-- device never has to type it. Needed for collaborative mode.
create table if not exists app_config (key text primary key, value text);
alter table app_config enable row level security;
do $$ begin
  create policy "authenticated full access" on app_config
    for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;

-- ── Verify row-level security lets signed-in users write ────────────────────
-- If saves fail with "row-level security policy" errors, inspect policies:
--   select * from pg_policies where tablename in ('monthly_sessions','monthly_transactions');
-- Both tables need select/insert/update/delete for the authenticated role, e.g.:
--   create policy "authenticated full access" on monthly_sessions
--     for all to authenticated using (true) with check (true);
--   create policy "authenticated full access" on monthly_transactions
--     for all to authenticated using (true) with check (true);
