import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql.functions import col

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

# Read from Glue Data Catalog (schema-on-read source)
df = glueContext.create_dynamic_frame.from_catalog(
    database=args["database"],
    table_name=args["table"]
).toDF()

# Bronze: all STRING + original column names (as per legend)
bronze = (
    df.select(
        col("customerid").cast("string").alias("CustomerId"),
        col("purchasedate").cast("string").alias("PurchaseDate"),
        col("product").cast("string").alias("Product"),
        col("price").cast("string").alias("Price"),
    )
)

bronze.write.mode("overwrite").parquet(args["out_path"])

job.commit()
