// Databricks notebook source

// === Configurations for Kinesis streams ===
// If you are using IAM roles to connect to a Kinesis stream (recommended), you do not need to set the access key and the secret key
// val awsAccessKeyId = "YOUR ACCESS KEY ID"
// val awsSecretKey = "YOUR SECRET KEY"
val kinesisStreamName = "jwhqun6d-input-stream"
val kinesisRegion = "ap-southeast-1" // e.g., "us-west-2"

// COMMAND ----------


import com.amazonaws.services.kinesis.model.PutRecordRequest
import com.amazonaws.services.kinesis.AmazonKinesisClientBuilder
import com.amazonaws.auth.{AWSStaticCredentialsProvider, BasicAWSCredentials}
import java.nio.ByteBuffer
import scala.util.Random
 
// Verify that the Kinesis settings have been set
//require(!awsAccessKeyId.contains("YOUR"), "AWS Access Key has not been set")
//require(!awsSecretKey.contains("YOUR"), "AWS Access Secret Key has not been set")
// require(!kinesisStreamName.contains("jwhqun6d"), "Kinesis stream has not been set")
// require(!kinesisRegion.contains("ap"), "Kinesis region has not been set")
 

// COMMAND ----------


val kinesis = spark.readStream
  .format("kinesis")
  .option("streamName", kinesisStreamName)
  .option("region", kinesisRegion)
  .option("initialPosition", "TRIM_HORIZON")
  //.option("awsAccessKey", awsAccessKeyId)
  //.option("awsSecretKey", awsSecretKey)
  .load()

// COMMAND ----------

// MAGIC %scala
// MAGIC // Create the low-level Kinesis Client from the AWS Java SDK.
// MAGIC val kinesisClient = AmazonKinesisClientBuilder.standard()
// MAGIC   .withRegion(kinesisRegion)
// MAGIC   // .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(awsAccessKeyId, awsSecretKey)))
// MAGIC   .build()
// MAGIC  
// MAGIC println(s"Putting words onto stream $kinesisStreamName")
// MAGIC var lastSequenceNumber: String = null
// MAGIC  
// MAGIC for (i <- 0 to 10) {
// MAGIC   val time = System.currentTimeMillis
// MAGIC   // Generate words: fox in sox
// MAGIC   for (word <- Seq("Through", "three", "cheese", "trees", "three", "free", "fleas", "flew", "While", "these", "fleas", "flew", "freezy", "breeze", "blew", "Freezy", "breeze", "made", "these", "three", "trees", "freeze", "Freezy", "trees", "made", "these", "trees", "cheese", "freeze", "That's", "what", "made", "these", "three", "free", "fleas", "sneeze")) {
// MAGIC     val data = s"$word"
// MAGIC     val partitionKey = s"$word"
// MAGIC     val request = new PutRecordRequest()
// MAGIC         .withStreamName(kinesisStreamName)
// MAGIC         .withPartitionKey(partitionKey)
// MAGIC         .withData(ByteBuffer.wrap(data.getBytes()))
// MAGIC     if (lastSequenceNumber != null) {
// MAGIC       request.setSequenceNumberForOrdering(lastSequenceNumber)
// MAGIC     }    
// MAGIC     val result = kinesisClient.putRecord(request)
// MAGIC     lastSequenceNumber = result.getSequenceNumber()
// MAGIC   }
// MAGIC   Thread.sleep(math.max(10000 - (System.currentTimeMillis - time), 0)) // loop around every ~10 seconds 
// MAGIC }

// COMMAND ----------

// MAGIC %scala
// MAGIC
// MAGIC kinesis.writeStream
// MAGIC   .format("delta")
// MAGIC   .option("checkpointLocation", "/tmp/kinesis-demo/_checkpoint")
// MAGIC   .table("kinesis_demo")

// COMMAND ----------

val result = spark.sql("select * from kinesis_demo")
display(result)
