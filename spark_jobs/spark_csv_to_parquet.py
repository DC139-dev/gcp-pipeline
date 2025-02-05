from pyspark.sql import SparkSession
from pyspark.sql.functions import lit
from conf import CONFIG

def main(input_path, output_path):
    spark = SparkSession.builder \
        .appName("CSV to Parquet Transformation") \
        .config("spark.sql.parquet.compression.codec", "snappy") \
        .getOrCreate()

    df = spark.read.option("header", "true").csv(input_path)
    df = df.withColumn("new_column", lit("000"))

    df.write.mode("overwrite").parquet(output_path)
    spark.stop()

if __name__ == "__main__":
    main(CONFIG["INPUT_CSV_PATH"], CONFIG["OUTPUT_PARQUET_PATH"])
