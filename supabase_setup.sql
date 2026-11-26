-- The Fire Rises: online room setup
-- Supabase Dashboard > SQL Editor > New query > paste all > Run
create table if not exists public.tf_game_rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[0-9]{6}$'),
  host_id uuid not null references auth.users(id) on delete cascade,
  guest_id uuid references auth.users(id) on delete set null,
  state jsonb,
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
alter table public.tf_game_rooms enable row level security;
drop policy if exists "participants can read room" on public.tf_game_rooms;
create policy "participants can read room" on public.tf_game_rooms for select to authenticated
using (auth.uid() = host_id or auth.uid() = guest_id);
revoke all on public.tf_game_rooms from anon, authenticated;
grant select on public.tf_game_rooms to authenticated;

drop function if exists public.tf_create_room();
create function public.tf_create_room()
returns table(id uuid, code text)
language plpgsql security definer set search_path = public
as $$
declare v_id uuid; v_code text; v_try int := 0;
begin
  if auth.uid() is null then raise exception 'ログインしてください'; end if;
  loop
    v_code := lpad((floor(random()*1000000))::int::text,6,'0');
    begin
      insert into public.tf_game_rooms(code,host_id) values(v_code,auth.uid()) returning tf_game_rooms.id into v_id;
      exit;
    exception when unique_violation then v_try := v_try + 1; if v_try > 10 then raise; end if;
    end;
  end loop;
  return query select v_id,v_code;
end; $$;

drop function if exists public.tf_join_room(text);
create function public.tf_join_room(p_code text)
returns table(id uuid, code text)
language plpgsql security definer set search_path = public
as $$
declare v_id uuid; v_code text;
begin
  if auth.uid() is null then raise exception 'ログインしてください'; end if;
  update public.tf_game_rooms r set guest_id=auth.uid()
   where r.code=p_code and r.guest_id is null and r.host_id<>auth.uid()
   returning r.id,r.code into v_id,v_code;
  if v_id is null then raise exception 'ルームが見つからないか、満員です'; end if;
  return query select v_id,v_code;
end; $$;

drop function if exists public.tf_update_room_state(uuid,jsonb);
create function public.tf_update_room_state(p_room_id uuid,p_state jsonb)
returns void language plpgsql security definer set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'ログインしてください'; end if;
  update public.tf_game_rooms r set state=p_state,updated_by=auth.uid()
   where r.id=p_room_id and (r.host_id=auth.uid() or r.guest_id=auth.uid());
  if not found then raise exception 'このルームを更新する権限がありません'; end if;
end; $$;

grant execute on function public.tf_create_room() to authenticated;
grant execute on function public.tf_join_room(text) to authenticated;
grant execute on function public.tf_update_room_state(uuid,jsonb) to authenticated;
-- Enable Realtime updates for room state changes.
do $$ begin
  alter publication supabase_realtime add table public.tf_game_rooms;
exception when duplicate_object then null;
end $$;
