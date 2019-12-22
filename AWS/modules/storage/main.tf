#---------storage/main.tf---------

# Create a random id, length two bytes
resource "random_id" "tf_bucket_id" {
  byte_length = 2  # will output something like "33346"
}

# Create the bucket
resource "aws_s3_bucket" "tf_code" {
    bucket        = "${var.project_name}-${random_id.tf_bucket_id.dec}"
    acl           = "private"

    force_destroy =  true  # Destroys the bucket even if there are objects in it.

    tags {
      Name = "tf_bucket"
    }
}