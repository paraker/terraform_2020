# Root Module overview
* Instantiates AWS infrastructure from local modules.
* Utilises terraform.tfvars to set variables for easy plan/apply.

Assumes these three variables are set:

    export AWS_ACCESS_KEY_ID="AKIAQL27H7V66VV25S3"
    export AWS_SECRET_ACCESS_KEY="i2Z0Vk5ZOJvO01uTuhTeEJKAL0LzuQ09HaCNBA"
    export AWS_DEFAULT_REGION=us-east-1

# Module README.md files
They describe what's new in the tf code, within that module. Do read them.

# Architecture
![Architecture](pictures/architecture.png)

# Modules
![Modules](pictures/modules.png)
