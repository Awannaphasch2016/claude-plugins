-- cockpit data maturity: felt/pace graduate from files to append-only tables
-- ops project · applied 2026-08-30 · append-only BY GRANTS (the ops_log pattern):
-- the writer role receives INSERT+SELECT and nothing else; UPDATE/DELETE grants
-- simply never exist. No RLS on purpose: these tables are role-gated, and RLS
-- without BYPASSRLS would block the scoped writer itself.

create table if not exists cockpit_felt (
  id           bigint generated always as identity primary key,
  felt_at      timestamptz not null,                 -- when the mark was MADE
  recorded_at  timestamptz not null default now(),   -- when the row LANDED
  transcript   text,
  word         text not null,   -- verbatim, uninterpreted — NO enum by charter
  note         text
);

create table if not exists cockpit_pace (
  id           bigint generated always as identity primary key,
  asof_at      timestamptz not null,
  recorded_at  timestamptz not null default now(),
  scope        text not null,
  run          text,
  reading      jsonb not null
);

-- Supabase default privileges may reach these via PostgREST roles: exclude them.
revoke all on cockpit_felt, cockpit_pace from public, anon, authenticated;

-- the scoped writer: can append and read, can never rewrite
do $$ begin
  if not exists (select from pg_roles where rolname='cockpit_writer') then
    create role cockpit_writer login password :'cockpit_writer_password'  -- pass via psql -v, NEVER versioned;
  end if;
end $$;
grant usage on schema public to cockpit_writer;
grant insert, select on cockpit_felt, cockpit_pace to cockpit_writer;
grant usage, select on sequence cockpit_felt_id_seq, cockpit_pace_id_seq to cockpit_writer;
