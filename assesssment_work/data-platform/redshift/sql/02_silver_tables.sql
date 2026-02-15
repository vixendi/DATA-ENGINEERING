drop table if exists silver.customers;
drop table if exists silver.user_profiles;
drop table if exists silver.sales;

create table silver.customers (
  client_id         bigint,
  first_name        varchar(256),
  last_name         varchar(256),
  email             varchar(512),
  registration_date date,
  state             varchar(128)
);

create table silver.user_profiles (
  email         varchar(512),
  full_name     varchar(512),
  first_name    varchar(256),
  last_name     varchar(256),
  state         varchar(128),
  birth_date    date,
  phone_number  varchar(64)
);

create table silver.sales (
  client_id      bigint,
  purchase_date  date,
  product_name   varchar(256),
  price          decimal(10,2)
);
