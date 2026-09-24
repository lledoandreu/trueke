-- 1. Añadir columnas de reputación y estrellas a la tabla de perfiles
alter table public.profiles 
add column if not exists average_rating numeric(3,2) default 0.00,
add column if not exists total_ratings integer default 0;

-- 2. Crear función PL/pgSQL para recalcular la reputación de forma automatizada
create or replace function public.handle_recalculate_user_reputation()
returns trigger as 10634
declare
  _receiver_id uuid;
  _avg_rating numeric(3,2);
  _total_count integer;
begin
  -- Identificar el ID del usuario receptor afectado por la mutación
  if (TG_OP = 'DELETE') then
    _receiver_id := old.receiver_id;
  else
    _receiver_id := new.receiver_id;
  end if;

  -- Calcular el promedio y el conteo total de las valoraciones de ese usuario
  select 
    coalesce(avg(rating), 0.00), 
    count(id)
  into 
    _avg_rating, 
    _total_count
  from public.user_reviews
  where receiver_id = _receiver_id;

  -- Actualizar de forma transaccional el perfil del usuario correspondiente
  update public.profiles
  set 
    average_rating = _avg_rating,
    total_ratings = _total_count,
    updated_at = now()
  where id = _receiver_id;

  return null;
end;
10634 language plpgsql security definer;

-- 3. Vincular el trigger de automatización a la tabla de valoraciones
drop trigger if exists on_review_mutation_recalculate_reputation on public.user_reviews;
create trigger on_review_mutation_recalculate_reputation
after insert or update or delete
on public.user_reviews
for each row
execute function public.handle_recalculate_user_reputation();
