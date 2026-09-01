-- Security expectations for the exposed database API.
-- These assertions are intended to be run with `supabase test db`.

begin;

select plan(5);

select is(
  has_function_privilege(
    'anon',
    'public.create_trade_offer(text,text,text)',
    'execute'
  ),
  false,
  'anon cannot execute create_trade_offer'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.create_trade_offer(text,text,text)',
    'execute'
  ),
  false,
  'authenticated cannot execute create_trade_offer directly'
);

select is(
  has_table_privilege(
    'authenticated',
    'public.trade_offers',
    'INSERT'
  ),
  false,
  'authenticated cannot insert directly into trade_offers'
);

select is(
  has_table_privilege(
    'authenticated',
    'public.trade_offers',
    'SELECT'
  ),
  true,
  'authenticated can select trade_offers'
);

select is(
  has_table_privilege(
    'anon',
    'public.profiles',
    'SELECT'
  ),
  false,
  'anon cannot select profiles'
);

select * from finish();

rollback;
