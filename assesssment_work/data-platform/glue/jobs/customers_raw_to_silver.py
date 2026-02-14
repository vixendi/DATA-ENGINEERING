import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql.functions import col, input_file_name, regexp_extract, to_date, trim, lower, when
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number

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

# Derive snapshot_date from path: .../raw/customers/2022-08-5/....
snapshot_date = regexp_extract(input_file_name(), r"/raw/customers/(\d{4}-\d{2}-\d{1,2})/", 1)

def clean_str(c):
    return when(trim(col(c)) == "", None).otherwise(trim(col(c)))

staged = (
    df
    .withColumn("snapshot_date", to_date(snapshot_date))
    .select(
        col("id").cast("bigint").alias("client_id"),
        clean_str("firstname").alias("first_name"),
        clean_str("lastname").alias("last_name"),
        when(trim(col("email")) == "", None).otherwise(lower(trim(col("email")))).alias("email"),
        to_date(trim(col("registrationdate"))).alias("registration_date"),
        clean_str("state").alias("state"),
        col("snapshot_date"),
    )
    .where(col("client_id").isNotNull() & col("snapshot_date").isNotNull())
)

# Because each day is a full snapshot, keep the latest snapshot record per client_id
w = Window.partitionBy("client_id").orderBy(col("snapshot_date").desc())
latest = staged.withColumn("rn", row_number().over(w)).where(col("rn") == 1).drop("rn", "snapshot_date")

latest.write.mode("overwrite").parquet(args["out_path"])

job.commit()
