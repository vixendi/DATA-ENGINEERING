create schema if not exists gold;

drop table if exists gold.user_profiles_enriched;

create table gold.user_profiles_enriched as
select
  c.client_id,

  -- fill missing names/state from profiles
  coalesce(nullif(trim(c.first_name), ''), split_part(trim(p.full_name), ' ', 1)) as first_name,
  coalesce(nullif(trim(c.last_name),  ''), split_part(trim(p.full_name), ' ', 2)) as last_name,
  c.email,
  c.registration_date,
  coalesce(nullif(trim(c.state), ''), p.state) as state,

  -- bring additional fields from profiles
  p.full_name,
  p.birth_date,
  p.phone_number
from silver.customers c
left join silver.user_profiles p
  on lower(c.email) = lower(p.email);
