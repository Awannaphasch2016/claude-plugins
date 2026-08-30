-- the ops project's ensure_rls event trigger auto-enabled RLS (discovered on
-- first insert — the canary doing its job). Per-command policies, never FOR ALL;
-- NO update/delete policies exist, so append-only holds at BOTH layers.
create policy cockpit_felt_insert on cockpit_felt for insert to cockpit_writer with check (true);
create policy cockpit_felt_select on cockpit_felt for select to cockpit_writer using (true);
create policy cockpit_pace_insert on cockpit_pace for insert to cockpit_writer with check (true);
create policy cockpit_pace_select on cockpit_pace for select to cockpit_writer using (true);
