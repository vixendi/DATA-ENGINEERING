from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.amazon.aws.operators.redshift_data import RedshiftDataOperator

from _settings import DEFAULT_AWS_REGION, REDSHIFT_DATABASE, REDSHIFT_SECRET_ARN, REDSHIFT_WORKGROUP

SQL_PATH = "sql/04_gold_enrichment.sql"  # MWAA path inside container

with DAG(
    dag_id="enrich_user_profiles",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # manual only
    catchup=False,
    default_args={"owner": "data-platform"},
    tags=["assessment", "gold", "redshift"],
) as dag:
    start = EmptyOperator(task_id="start")

    run_merge = RedshiftDataOperator(
        task_id="redshift_merge_gold",
        region=DEFAULT_AWS_REGION,
        workgroup_name=REDSHIFT_WORKGROUP,
        database=REDSHIFT_DATABASE,
        secret_arn=REDSHIFT_SECRET_ARN,
        sql=f"{{% include '{SQL_PATH}' %}}",
        wait_for_completion=True,
    )

    end = EmptyOperator(task_id="end")

    start >> run_merge >> end
