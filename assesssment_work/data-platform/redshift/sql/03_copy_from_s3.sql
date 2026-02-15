copy silver.customers
from 's3://datalake-842940822473-dev/silver/customers/'
iam_role 'arn:aws:iam::842940822473:role/data-platform-dev-redshift-s3-role'
format as parquet;

copy silver.user_profiles
from 's3://datalake-842940822473-dev/silver/user_profiles/'
iam_role 'arn:aws:iam::842940822473:role/data-platform-dev-redshift-s3-role'
format as parquet;

copy silver.sales
from 's3://datalake-842940822473-dev/silver/sales/'
iam_role 'arn:aws:iam::842940822473:role/data-platform-dev-redshift-s3-role'
format as parquet;
