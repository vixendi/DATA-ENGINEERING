import sys
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F

"""
Sales (Glue Catalog raw_sales) -> Silver parquet partitioned by purchase_date
Fix: ensure purchase_date is a real column in parquet (not only a partition folder name).
Fix: read from Glue Catalog via from_catalog (avoids ParseException with '-' in db name).
Args are OPTIONAL to allow running without Terraform DefaultArguments.
"""

sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

def _get_arg(name: str, default: str) -> str:
    prefix = f"--{name}="
    for a in sys.argv:
        if a.startswith(prefix):
            return a.split("=", 1)[1]
    return default

source_db = _get_arg("SOURCE_DB", "data-platform_glue_db")
source_table = _get_arg("SOURCE_TABLE", "raw_sales")
target_path = _get_arg("TARGET_S3_PATH", "s3://datalake-842940822473-dev/silver/sales").rstrip("/")

job = Job(glue_context)
job.init(args["JOB_NAME"], args)

# Read from Glue Data Catalog (safe for db names with '-')
dyf = glue_context.create_dynamic_frame.from_catalog(
    database=source_db,
    table_name=source_table
)
df = dyf.toDF()

# Crawler lowercases column names
cols = {c.lower(): c for c in df.columns}

def c(name: str):
    key = name.lower()
    if key not in cols:
        raise RuntimeError(f"Missing column '{name}'. Available: {df.columns}")
    return F.col(cols[key])

df2 = (
    df.select(
        c("customerid").cast("bigint").alias("client_id"),
        F.to_date(c("purchasedate").cast("string"), "yyyy-M-d").alias("purchase_date"),
        F.trim(c("product").cast("string")).alias("product_name"),
        F.regexp_replace(c("price").cast("string"), r"[^0-9.]", "").cast("decimal(10,2)").alias("price"),
    )
    .filter(F.col("purchase_date").isNotNull() & F.col("client_id").isNotNull())
)

(df2.write
    .mode("overwrite")
    .partitionBy("purchase_date")
    .parquet(target_path)
)

job.commit()
