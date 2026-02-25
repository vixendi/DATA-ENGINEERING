from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator

from _settings import (
    DEFAULT_AWS_REGION,
    GLUE_DATABASE,
    GLUE_JOB_USER_PROFILES_RAW_TO_SILVER,
)

with DAG(
    dag_id="process_user_profiles",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # manual only
    catchup=False,
    default_args={"owner": "data-platform"},
    tags=["assessment", "user_profiles", "glue"],
) as dag:
    start = EmptyOperator(task_id="start")

    raw_to_silver = GlueJobOperator(
        task_id="user_profiles_raw_to_silver",
        job_name=GLUE_JOB_USER_PROFILES_RAW_TO_SILVER,
        region_name=DEFAULT_AWS_REGION,
        wait_for_completion=True,
        verbose=True,
        script_args={
            "--SOURCE_DB": GLUE_DATABASE,
            "--SOURCE_TABLE": "raw_user_profiles_json",
            "--TARGET_S3_PATH": "s3://{{ var.value.datalake_bucket if var.value.datalake_bucket else '" + "DUMMY" + "' }}/silver/user_profiles/",
        },
    )

    end = EmptyOperator(task_id="end")

    start >> raw_to_silver >> end
