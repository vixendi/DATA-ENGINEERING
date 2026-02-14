import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql.functions import col, to_date, trim, regexp_replace
from pyspark.sql.types import DecimalType

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "in_path",
    "out_path",
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

df = spark.read.parquet(args["in_path"])

# Clean + rename + type casting
# PurchaseDate expected like '2022-09-1' or '2022-09-01' -> normalize by Spark to_date (yyyy-MM-dd works for both)
clean_price = regexp_replace(trim(col("Price")), r"[^0-9\.\-]", "")

silver = (
    df.select(
        col("CustomerId").cast("bigint").alias("client_id"),
        to_date(trim(col("PurchaseDate"))).alias("purchase_date"),
        trim(col("Product")).alias("product_name"),
        clean_price.cast(DecimalType(10, 2)).alias("price"),
    )
    .where(col("client_id").isNotNull() & col("purchase_date").isNotNull() & col("product_name").isNotNull())
)

# Partition by purchase_date
(
    silver.write
    .mode("overwrite")
    .partitionBy("purchase_date")
    .parquet(args["out_path"])
)

job.commit()
