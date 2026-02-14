select
  e.state,
  count(*) as tv_purchases
from silver.sales s
join gold.user_profiles_enriched e
  on s.client_id = e.client_id
where
  s.product_name ilike '%tv%'
  and s.purchase_date >= date '2022-09-01'
  and s.purchase_date <= date '2022-09-10'
  and e.birth_date is not null
  and datediff(year, e.birth_date, s.purchase_date) between 20 and 30
group by e.state
order by tv_purchases desc
limit 1;
