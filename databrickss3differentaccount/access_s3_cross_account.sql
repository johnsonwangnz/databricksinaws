-- Databricks notebook source
-- MAGIC %python
-- MAGIC df = spark.range(10)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df.write.mode("overwrite").save("s3a://jwhqun6d-account-b/range_delta")

-- COMMAND ----------

create table test_delta
location "s3a://jwhqun6d-account-b/range_delta"

-- COMMAND ----------

select * from test_delta
