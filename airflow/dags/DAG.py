from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'data_pipeline',
    default_args=default_args,
    description='Pipeline de dados usando Embulk',
    schedule_interval='@daily',
    start_date=datetime(2025, 2, 1),
    catchup=False,
)

extract_csv_task = BashOperator(
    task_id='extract_csv',
    bash_command='embulk run /workspace/config/extract_csv.yml',
    dag=dag,
)

extract_postgres_task = BashOperator(
    task_id='extract_postgres',
    bash_command='embulk run /workspace/config/extract_postgres.yml',
    dag=dag,
)

load_to_db_task = BashOperator(
    task_id='load_to_db',
    bash_command='embulk run /workspace/config/load_to_db.yml',
    dag=dag,
)

extract_csv_task >> load_to_db_task
extract_postgres_task >> load_to_db_task