import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql.functions import col, trim, lower, split, to_date, when

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "database",
    "table",
    "out_path",
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

df = glueContext.create_dynamic_frame.from_catalog(
    database=args["database"],
    table_name=args["table"]
).toDF()

def clean_str_col(c):
    return when(trim(col(c)) == "", None).otherwise(trim(col(c)))

base = (
    df.select(
        when(trim(col("email")) == "", None).otherwise(lower(trim(col("email")))).alias("email"),
        clean_str_col("full_name").alias("full_name"),
        clean_str_col("state").alias("state"),
        to_date(trim(col("birth_date"))).alias("birth_date"),
        clean_str_col("phone_number").alias("phone_number"),
    )
    .where(col("email").isNotNull())
)

# Optional: split full_name -> first/last (best-effort)
name_parts = split(col("full_name"), r"\s+")
silver = base.select(
    col("email"),
    col("full_name"),
    when(col("full_name").isNull(), None).otherwise(name_parts.getItem(0)).alias("first_name"),
    when(col("full_name").isNull(), None).otherwise(name_parts.getItem(1)).alias("last_name"),
    col("state"),
    col("birth_date"),
    col("phone_number"),
)

silver.write.mode("overwrite").parquet(args["out_path"])

job.commit()
