from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator

from _settings import (
    DEFAULT_AWS_REGION,
    GLUE_DATABASE,
    GLUE_JOB_SALES_BRONZE_TO_SILVER,
    GLUE_JOB_SALES_RAW_TO_BRONZE,
)

with DAG(
    dag_id="process_sales",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # run manually or set cron later
    catchup=False,
    default_args={"owner": "data-platform"},
    tags=["assessment", "sales", "glue"],
) as dag:
    start = EmptyOperator(task_id="start")

    raw_to_bronze = GlueJobOperator(
        task_id="sales_raw_to_bronze",
        job_name=GLUE_JOB_SALES_RAW_TO_BRONZE,
        region_name=DEFAULT_AWS_REGION,
        wait_for_completion=True,
        verbose=True,
        script_args={
            "--SOURCE_DB": GLUE_DATABASE,
            "--SOURCE_TABLE": "raw_sales",
            "--TARGET_S3_PATH": "s3://{{ var.value.datalake_bucket if var.value.datalake_bucket else '" + "DUMMY" + "' }}/bronze/sales/",
        },
    )

    bronze_to_silver = GlueJobOperator(
        task_id="sales_bronze_to_silver",
        job_name=GLUE_JOB_SALES_BRONZE_TO_SILVER,
        region_name=DEFAULT_AWS_REGION,
        wait_for_completion=True,
        verbose=True,
        script_args={
            "--SOURCE_DB": GLUE_DATABASE,
            "--SOURCE_TABLE": "bronze_sales",
            "--TARGET_S3_PATH": "s3://{{ var.value.datalake_bucket if var.value.datalake_bucket else '" + "DUMMY" + "' }}/silver/sales/",
        },
    )

    end = EmptyOperator(task_id="end")

    start >> raw_to_bronze >> bronze_to_silver >> end
