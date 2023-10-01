-- Databricks notebook source
-- MAGIC %python
-- MAGIC spark.conf.set("da.catalog", 'catalog1')
-- MAGIC spark.conf.set("schema_name", 'my_schema')
-- MAGIC spark.conf.set("catalog.schema.table", 'catalog1.my_schema.silver')
-- MAGIC spark.conf.set("table_name", 'silver')

-- COMMAND ----------

-- this is in preview, not available for now
SELECT
  user_identity.email as `User`,
  IFNULL(request_params.full_name_arg,
    request_params.name)
    AS `Table`,
    action_name AS `Type of Access`,
    event_time AS `Time of Access`
FROM system.access.audit
WHERE request_params.full_name_arg = '{{catalog.schema.table}}'
  OR (request_params.name = '{{table_name}}'
  AND request_params.schema_name = '{{schema_name}}')
  AND action_name
    IN ('createTable','getTable','deleteTable')
  AND datediff(now(), event_date) < 1
ORDER BY event_date DESC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df = spark.read.format("json").load("s3a://jwhqun6d-logdelivery-databricks/audit-logs")
-- MAGIC df.createOrReplaceTempView("audit_logs")

-- COMMAND ----------

select * from audit_logs

-- COMMAND ----------

--select * from audit_logs where workspaceid = 0
-- select distinct(serviceName) from audit_logs where workspaceid = 0
select distinct(actionName) from audit_logs where workspaceid = 0

-- COMMAND ----------

select distinct(serviceName) from audit_logs where workspaceid != 0
-- select distinct(actionName) from audit_logs where workspaceid != 0

-- COMMAND ----------

--List the users who accessed Databricks and from where.
SELECT DISTINCT userIdentity.email, sourceIPAddress
FROM audit_logs
WHERE serviceName = "accounts" AND actionName LIKE "%login%"

-- COMMAND ----------

--Check the Apache Spark versions used.
SELECT requestParams.spark_version, COUNT(*)
FROM audit_logs
WHERE serviceName = "clusters" AND actionName = "create"
GROUP BY requestParams.spark_version

-- COMMAND ----------

-- Check table data access.
SELECT *
FROM audit_logs
WHERE serviceName = "sqlPermissions" AND actionName = "requestPermissions"
