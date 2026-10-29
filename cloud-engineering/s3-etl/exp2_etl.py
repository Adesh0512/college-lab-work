import os
import boto3
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when

# --------------------------------------------------
# AWS S3 DETAILS
# --------------------------------------------------

BUCKET = os.environ.get("BUCKET", "your-bucket-name")
S3_FILE = os.environ.get("S3_FILE", "input.csv")
LOCAL_FILE = os.environ.get("LOCAL_FILE", "input.csv")

# --------------------------------------------------
# AMAZON RDS POSTGRESQL DETAILS
# --------------------------------------------------

RDS_ENDPOINT = os.environ.get("RDS_ENDPOINT", "your-db.xxxxxx.region.rds.amazonaws.com")
RDS_PORT = os.environ.get("RDS_PORT", "5432")
RDS_DATABASE = os.environ.get("RDS_DATABASE", "postgres")
RDS_USERNAME = os.environ.get("RDS_USERNAME", "postgres")
RDS_PASSWORD = os.environ.get("RDS_PASSWORD", "")

# --------------------------------------------------
# STEP 1: EXTRACT DATA FROM S3
# --------------------------------------------------

s3 = boto3.client(
    "s3",
    region_name="eu-north-1"
)

print("Downloading CSV from S3...")

s3.download_file(
    BUCKET,
    S3_FILE,
    LOCAL_FILE
)

print("S3 download successful.")

# --------------------------------------------------
# STEP 2: CREATE SPARK SESSION
# --------------------------------------------------

spark = (
    SparkSession.builder
    .appName("CDE-Lab2-ETL")
    .config(
        "spark.jars.packages",
        "org.postgresql:postgresql:42.7.7"
    )
    .getOrCreate()
)

# --------------------------------------------------
# STEP 3: READ CSV USING SPARK
# --------------------------------------------------

df = (
    spark.read
    .option("header", True)
    .option("inferSchema", True)
    .csv(LOCAL_FILE)
)

print("\nOriginal Data:")
df.show()

# --------------------------------------------------
# STEP 4: TRANSFORM DATA
# --------------------------------------------------

transformed_df = (
    df
    .dropna()
    .withColumn(
        "result",
        when(col("marks") >= 50, "PASS")
        .otherwise("FAIL")
    )
)

print("\nTransformed Data:")
transformed_df.show()

# --------------------------------------------------
# STEP 5: LOAD DATA INTO AMAZON RDS
# --------------------------------------------------

jdbc_url = (
    f"jdbc:postgresql://"
    f"{RDS_ENDPOINT}:{RDS_PORT}/{RDS_DATABASE}"
)

connection_properties = {
    "user": RDS_USERNAME,
    "password": RDS_PASSWORD,
    "driver": "org.postgresql.Driver"
}

print("\nLoading data into Amazon RDS...")

transformed_df.write \
    .mode("overwrite") \
    .jdbc(
        jdbc_url,
        "student_results",
        properties=connection_properties
    )

print("\nETL pipeline completed successfully!")

# --------------------------------------------------
# STEP 6: STOP SPARK
# --------------------------------------------------

spark.stop()