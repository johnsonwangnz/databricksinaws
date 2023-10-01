
data "aws_caller_identity"  "current" {}
resource "aws_athena_workgroup" "workgroupa" {
  name = "workgroupA"

  force_destroy = true
  configuration {

    #enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena-workshop-bucket.bucket}/output/"


    }
  }
}



resource "aws_athena_data_catalog" "my-athena-data-catalog" {
  name        = "my-athena-data-catalog"
  description = "Data Catalog"
  #type - (Required) Type of data catalog: LAMBDA for a federated catalog, GLUE for AWS Glue Catalog, or HIVE for an external hive metastore.

  type        = "GLUE"

  parameters = {
    catalog-id = data.aws_caller_identity.current.account_id
  }
}


resource "aws_athena_database" "my-athena-database" {
  name        = "my_athena_database"

  force_destroy = true
  bucket = aws_s3_bucket.athena-workshop-bucket.id
}



resource "aws_athena_named_query" "amazonreviewstsv" {
  name      = "Athena_create_amazon_reviews_tsv"
  description = "Create table amazon_reviews_tsv"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    CREATE EXTERNAL TABLE amazon_reviews_tsv (
                    marketplace string,
                    customer_id string,
                    review_id string,
                    product_id string,
                    product_parent string,
                    product_title string,
                    product_category string,
                    star_rating int,
                    helpful_votes int,
                    total_votes int,
                    vine string,
                    verified_purchase string,
                    review_headline string,
                    review_body string,
                    review_date date,
                    year int)
                    ROW FORMAT DELIMITED
                    FIELDS TERMINATED BY '\t'
                    ESCAPED BY '\\'
                    LINES TERMINATED BY '\n'
                    LOCATION
                    's3://amazon-reviews-pds/tsv/'
                    TBLPROPERTIES ("skip.header.line.count"="1");
EOT
}


resource "aws_athena_named_query" "amazonreviewsparquet" {
  name      = "Athena_create_amazon_reviews_parquet"
  description = "Create table amazon_reviews_parquet"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    CREATE EXTERNAL TABLE amazon_reviews_parquet(
                    marketplace string,
                    customer_id string,
                    review_id string,
                    product_id string,
                    product_parent string,
                    product_title string,
                    star_rating int,
                    helpful_votes int,
                    total_votes int,
                    vine string,
                    verified_purchase string,
                    review_headline string,
                    review_body string,
                    review_date bigint,
                    year int)
                    PARTITIONED BY (product_category string)
                    ROW FORMAT SERDE
                    'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
                    STORED AS INPUTFORMAT
                    'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
                    OUTPUTFORMAT
                    'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
                    LOCATION
                    's3://amazon-reviews-pds/parquet/';

                    /* Next we will load the partitions for this table */
                    MSCK REPAIR TABLE amazon_reviews_parquet;

                    /* Check the partitions */
                    SHOW PARTITIONS amazon_reviews_parquet;

EOT
}


resource "aws_athena_named_query" "qryamazonreviewstsv" {
  name      = "Athena_compare_reviews"
  description = "Reviews Ratings table amazon_reviews_tsv"

  database  = aws_athena_database.my-athena-database.name

  query     = <<-EOT
                    /* Let's try to find the products and their corresponding category by number of reviews and avg star rating */
                    SELECT product_id, product_category, product_title, count(*) as num_reviews, avg(star_rating) as avg_stars
                    FROM amazon_reviews_tsv
                    GROUP BY 1, 2, 3
                    ORDER BY 4 DESC
                    limit 10;

                    /* Let's try to find the products and their corresponding category by number of reviews and avg star rating on parquet table */
                    SELECT product_id, product_category, product_title, count(*) as num_reviews, avg(star_rating) as avg_stars
                    FROM amazon_reviews_parquet
                    GROUP BY 1, 2, 3
                    ORDER BY 4 DESC
                    limit 10;

                    /* Let's try to find the products by number of reviews and avg star rating in Mobile_Apps category */
                    SELECT product_id, product_title, count(*) as num_reviews, avg(star_rating) as avg_stars
                    FROM amazon_reviews_tsv where product_category='Mobile_Apps'
                    GROUP BY 1, 2
                    ORDER BY 3 DESC
                    limit 10;

                    /* Let's try to find the products by number of reviews and avg star rating in Mobile_Apps category */
                    SELECT product_id, product_title, count(*) as num_reviews, avg(star_rating) as avg_stars
                    FROM amazon_reviews_parquet where product_category='Mobile_Apps'
                    GROUP BY 1, 2
                    ORDER BY 3 DESC
                    limit 10;

EOT
}


resource "aws_athena_named_query" "TopReviewedStarRatedProductsv" {
  name      = "Athena_create_view_top_rated"
  description = "Create View TopRatedProducts"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    CREATE view topratedproducts AS
                    SELECT product_category,
                            product_id,
                            product_title,
                            count(*) count_reviews
                    FROM amazon_reviews_parquet
                    WHERE star_rating=5
                    GROUP BY  1, 2, 3
                    ORDER BY  4 desc;

                    Select * from topratedproducts limit 10;

EOT
}


resource "aws_athena_named_query" "ctas" {
  name      = "Athena_ctas_reviews"
  description = "CTAS Amazon Reviews by Marketplace"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    CREATE TABLE amazon_reviews_by_marketplace
                    WITH ( format='PARQUET', parquet_compression = 'SNAPPY', partitioned_by = ARRAY['marketplace', 'year'],
                    external_location =   's3://<<Athena-WorkShop-Bucket>>/athena-ctas-insert-into/') AS
                    SELECT customer_id,
                            review_id,
                            product_id,
                            product_parent,
                            product_title,
                            product_category,
                            star_rating,
                            helpful_votes,
                            total_votes,
                            verified_purchase,
                            review_headline,
                            review_body,
                            review_date,
                            marketplace,
                            year(review_date) AS year
                    FROM amazon_reviews_tsv
                    WHERE "$path" LIKE '%tsv.gz';

                    /* Let's try to find the products and their corresponding category by number of reviews and avg star rating for US marketplace in year 2015 */

                    SELECT product_id,
                            product_category,
                            product_title,
                            count(*) AS num_reviews,
                            avg(star_rating) AS avg_stars
                    FROM amazon_reviews_by_marketplace
                    WHERE marketplace='US'
                    AND year=2015
                    GROUP BY  1, 2, 3
                    ORDER BY  4 DESC limit 10;

EOT
}


resource "aws_athena_named_query" "comparereviews" {
  name      = "Athena_compare_reviews_marketplace"
  description = "Compare query performance"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    SELECT product_id, COUNT(*) FROM amazon_reviews_by_marketplace
                    WHERE marketplace='US' AND year = 2013
                    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

                    SELECT product_id, COUNT(*) FROM amazon_reviews_parquet
                    WHERE marketplace='US' AND year = 2013
                    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

                    SELECT product_id, COUNT(*) FROM amazon_reviews_tsv
                    WHERE marketplace='US' AND extract(year from review_date) = 2013
                    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;
EOT
}


resource "aws_athena_named_query" "flights" {
  name      = "Athena_flight_delay_60"
  description = "Top 10 routes delayed by more than 1 hour"

  database  = aws_athena_database.my-athena-database.name
  query     = <<-EOT
                    SELECT origin, dest, count(*) as delays
                    FROM flight_delay_parquet
                    WHERE depdelayminutes > 60
                    GROUP BY origin, dest
                    ORDER BY 3 DESC
                    LIMIT 10;
EOT
}
