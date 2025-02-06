# Pipeline de Dados com Airflow, Embulk e PostgreSQL

Este projeto implementa um pipeline de dados que extrai dados de um arquivo CSV e de um banco de dados PostgreSQL, salva os dados no sistema de arquivos local e, em seguida, carrega os dados em um banco de dados PostgreSQL de destino. O pipeline é orquestrado usando o Apache Airflow e utiliza o Embulk para a extração e carga de dados.

## Ferramentas Utilizadas

- **Apache Airflow**: Orquestração do pipeline.
- **Embulk**: Extração e carga de dados.
- **PostgreSQL**: Banco de dados de origem e destino.
- **Docker**: Contêinerização do ambiente de execução.

## Estrutura do Projeto

A estrutura do projeto é organizada da seguinte forma:

```
prj_indicium/
├── airflow/
│   ├── dags/
│   │   └── DAG.py
│   ├── logs/
│   ├── plugins/
│   ├── config/
│   ├── data/
│   │   └── northwind.sql
│   └── docker-compose.yaml
├── embulk/
│   ├── config/
│   │   ├── extract_csv.yaml
│   │   └── load_to_db.yaml
│   ├── input/
│   │   └── order_details.csv
│   ├── output/
│   ├── Dockerfile
│   └── entrypoint.sh
└── README.md
```

## Configuração do Ambiente

### Pré-requisitos

- Docker e Docker Compose instalados.
- Acesso a um terminal.

### Passos para Configuração

1. **Clone o Repositório**:

 Primeiro, clone o repositório do projeto para o seu ambiente local:

 ```bash
 git clone <repositório-do-projeto>
 cd prj_indicium
 ```

2. **Construa e Inicie os Contêineres**:

 No diretório raiz do projeto, execute o seguinte comando para construir e iniciar os contêineres Docker para o Airflow e o Embulk:

 ```bash
 docker-compose up -d
 ```

 Isso irá configurar o ambiente necessário para executar o pipeline.

3. **Configure o Airflow**:

 Acesse o painel do Airflow em [http://localhost:8080](http://localhost:8080). No painel, crie uma conexão para o banco de dados PostgreSQL com as seguintes configurações:

 - Tipo de conexão: PostgreSQL
 - Host: db
 - Schema: northwind
 - Login: northwind_user
 - Senha: thewindisblowing
 - Porta: 5432

4. **Prepare os Dados**:

 Certifique-se de que o arquivo CSV (`order_details.csv`) esteja no diretório `embulk/input`. Além disso, o banco de dados PostgreSQL de origem deve estar populado com os dados do Northwind.

## Executando o Pipeline

### Executar o DAG no Airflow:

No painel do Airflow, habilite e execute o DAG chamado `data_pipeline`. O DAG irá realizar as seguintes etapas:

1. Extrair dados do CSV e do PostgreSQL.
2. Salvar os dados no sistema de arquivos local.
3. Carregar os dados no banco de dados PostgreSQL de destino.

### Verificar os Resultados:

Os dados extraídos serão salvos em `/workspace/output`. Para verificar os dados carregados, acesse o banco de dados PostgreSQL de destino e consulte a tabela `order_details`.

## Detalhes dos Arquivos de Configuração

### `extract_csv.yaml`

Este arquivo configura o Embulk para extrair dados do arquivo CSV:

```yaml
in:
  type: file
  path_prefix: "/workspace/input/order_details.csv"
  parser:
  type: csv
  columns:
  - {name: order_id, type: long}
  - {name: product_id, type: long}
  - {name: unit_price, type: double}
  - {name: quantity, type: long}
  - {name: discount, type: double}
out:
  type: file
  path_prefix: "/workspace/output/order_details"
  file_ext: .csv
```

### `load_to_db.yaml`

Este arquivo configura o Embulk para carregar dados no PostgreSQL:

```yaml
in:
  type: file
  path_prefix: "/workspace/output/order_details"
  parser:
  type: csv
out:
  type: postgresql
  host: db
  port: 5432
  user: northwind_user
  password: thewindisblowing
  database: northwind
  table: order_details
```

### `DAG.py`

Este arquivo define o DAG no Airflow:

```python
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

load_to_db_task = BashOperator(
  task_id='load_to_db',
  bash_command='embulk run /workspace/config/load_to_db.yml',
  dag=dag,
)

extract_csv_task >> load_to_db_task
```