-- Databricks notebook source
SHOW DATABASES

-- COMMAND ----------

USE my_athena_database

-- COMMAND ----------

-- MAGIC %python
-- MAGIC s3_bucket = "jwhqun6d-athena-workshop"
-- MAGIC (spark.range(10)
-- MAGIC       .write
-- MAGIC       .format("parquet")
-- MAGIC       .mode("overwrite")
-- MAGIC       .save(f"s3a://{s3_bucket}/test_parquet")
-- MAGIC )

-- COMMAND ----------

CREATE table test_parquet
USING PARQUET
LOCATION 's3://jwhqun6d-athena-workshop/test_parquet';

-- COMMAND ----------

select * from test_parquet

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC (spark.range(10)
-- MAGIC       .write
-- MAGIC       .format("delta")
-- MAGIC       .mode("overwrite")
-- MAGIC       .save(f"s3a://{s3_bucket}/test_delta")
-- MAGIC )

-- COMMAND ----------

CREATE  table test_delta
USING DELTA
LOCATION "s3://jwhqun6d-athena-workshop/test_delta"

-- COMMAND ----------

CREATE TABLE department
(
  deptcode  INT,
  deptname  STRING,
  location  STRING
);

INSERT INTO department VALUES
  (10, 'FINANCE', 'EDINBURGH'),
  (20, 'SOFTWARE', 'PADDINGTON'),
  (30, 'SALES', 'MAIDSTONE'),
  (40, 'MARKETING', 'DARLINGTON'),
  (50, 'ADMIN', 'BIRMINGHAM');

-- COMMAND ----------

create database if not exists aws_airlifts_glue
location "s3://jwhqun6d-athena-workshop/air_lifts"

-- COMMAND ----------

use aws_airlifts_glue

-- COMMAND ----------

CREATE TABLE department
(
  deptcode  INT,
  deptname  STRING,
  location  STRING
);

INSERT INTO department VALUES
  (10, 'FINANCE', 'EDINBURGH'),
  (20, 'SOFTWARE', 'PADDINGTON'),
  (30, 'SALES', 'MAIDSTONE'),
  (40, 'MARKETING', 'DARLINGTON'),
  (50, 'ADMIN', 'BIRMINGHAM');

-- COMMAND ----------

CREATE TABLE external_department
(
  deptcode  INT,
  deptname  STRING,
  location  STRING
)
Location "s3://jwhqun6d-athena-workshop/air_lifts/external_department";

INSERT INTO external_department VALUES
  (10, 'FINANCE', 'EDINBURGH'),
  (20, 'SOFTWARE', 'PADDINGTON'),
  (30, 'SALES', 'MAIDSTONE'),
  (40, 'MARKETING', 'DARLINGTON'),
  (50, 'ADMIN', 'BIRMINGHAM');

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC (spark.range(10)
-- MAGIC       .write
-- MAGIC       .format("delta")
-- MAGIC       .mode("overwrite")
-- MAGIC       .save(f"s3://jwhqun6d-athena-workshop/air_lifts/test_delta")
-- MAGIC )

-- COMMAND ----------

CREATE  table test_delta
USING DELTA
LOCATION "s3://jwhqun6d-athena-workshop/air_lifts/test_delta"

-- COMMAND ----------

select * from test_delta
