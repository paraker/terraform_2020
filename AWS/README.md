# Root Module overview
Instantiates AWS infrastructure from local modules.
Utilises terraform.tfvars to set variables for easy plan/apply.

Assumes these three variables are set:

    export AWS_ACCESS_KEY_ID="AKIAQL27H7VF66VV25S3"
    export AWS_SECRET_ACCESS_KEY="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"
    export AWS_DEFAULT_REGION=us-east-1

# Architecture
![Architecture](pictures/architecture.png)

# Modules
![Modules](pictures/modules.png)
