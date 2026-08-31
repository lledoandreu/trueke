-- Security expectations for the exposed database API.
-- These assertions are intended to be run with `supabase test db` in the
-- project's linked/local database environment.

begin;

select has_function_privilege(
  'anon',
  'public.create_trade_offer(text,text,text)',
  'execute'
) = false as create_trade_offer_not_public;

select has_function_privilege(
  'authenticated',
  'public.create_trade_offer(text,text,text)',
  'execute'
) = true as create_trade_offer_for_authenticated;

select has_table_privilege(
  'authenticated',
  'public.trade_offers',
  'INSERT'
) = false as trade_offers_insert_not_direct;

select has_table_privilege(
  'authenticated',
  'public.trade_offers',
  'SELECT'
) = true as trade_offers_select_allowed;

select has_table_privilege(
  'anon',
  'public.profiles',
  'SELECT'
) = false as profiles_not_public;

rollback;
