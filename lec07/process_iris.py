from __future__ import annotations

import os
from typing import Any, Dict

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.email import EmailOperator
from airflow.operators.python import PythonOperator

from python_scripts.train_model import process_iris_data


DEFAULT_ARGS: Dict[str, Any] = {
    "owner": "Denys_Shcherbyna",
    "depends_on_past": False,
    "retries": 0,
}

# If ALERT_EMAIL is not specified, send to the email address from which we are sending.
ALERT_EMAIL: str = os.getenv(
    "ALERT_EMAIL",
    os.getenv("SMTP_MAIL_FROM", "data_iris@meta.ua"),
)

# Mail template (Jinja + XCom)
EMAIL_HTML_TEMPLATE: str = """
<h3>Iris ML pipeline report for {{ ds }}</h3>
<p>DAG <b>{{ dag.dag_id }}</b> completed successfully.</p>

<p><b>Run timestamp:</b> {{ ts }}</p>

{% set metrics = ti.xcom_pull(task_ids='train_iris_model') or {} %}

<ul>
  <li>
    Full model test accuracy:
    {{ metrics.get('full_model_accuracy', 'n/a') }}
  </li>
  <li>
    Top-5 features model test accuracy:
    {{ metrics.get('top5_model_accuracy', 'n/a') }}
  </li>
  <li>
    Top features:
    {{ (metrics.get('top_features', []) | join(', ')) or 'n/a' }}
  </li>
</ul>

<p>Processed date (logical date): <b>{{ ds }}</b></p>

<p>Best regards,<br/>Iris ML pipeline</p>
"""


with DAG(
    dag_id="process_iris",
    description=(
        "Run dbt transformation for Iris dataset, train ML model and "
        "send email notification with metrics."
    ),
    default_args=DEFAULT_ARGS,
    start_date=pendulum.datetime(2025, 4, 22, 1, 0, tz="Europe/Kiev"),
    end_date=pendulum.datetime(2025, 4, 24, 23, 59, tz="Europe/Kiev"),
    schedule_interval="0 1 * * *",  # 01:00 Kiev time
    catchup=False,
    tags=["iris", "ml", "dbt"],
) as dag:

    # 1) dbt-transformation iris_processed
    run_dbt_iris_model = BashOperator(
        task_id="run_dbt_iris_model",
        bash_command=(
            "cd /opt/airflow/dags/dbt/homework && "
            "dbt run "
            "--profiles-dir /opt/airflow/dags/dbt "
            "--select +iris_processed "
            "--vars 'process_date: {{ ds }}'"
        ),
    )

    # 2) Training the model by PythonOperator
    # process_iris_data returns a dict with metrics and goes to XCom
    train_iris_model = PythonOperator(
        task_id="train_iris_model",
        python_callable=process_iris_data,
        op_kwargs={
            # If there is a filter by date,
            # the function will be able to use this parameter
            "process_date": "{{ ds }}",
        },
    )

    # 3) Sending a letter via EmailOperator
    send_iris_report_email = EmailOperator(
        task_id="send_iris_report_email",
        to=[ALERT_EMAIL],
        subject="Iris ML pipeline succeeded for {{ ds }}",
        html_content=EMAIL_HTML_TEMPLATE,
    )

    run_dbt_iris_model >> train_iris_model >> send_iris_report_email
