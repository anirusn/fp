# Terraform Configuration Deployment Guide

To deploy this Terraform configuration, follow the steps below:

1. **Clone this Git Repository:**
   - Clone this repository to your local machine using the following command:
     ```
     git clone <url>
     ```

2. **Generate SSH Key Pair:**
   - Generate an SSH key pair

3. **Set Path of the Keys:**
   - Set the path of the generated SSH key pair to the `aws_key_pair` resource in each environment in `main.tf`.

4. **Create S3 Buckets:**
   - Create an S3 bucket for each environment (Dev, Staging, Prod) and set the bucket names at the top of `main.tf`.

5. **Set Image Bucket:**
   - Create another S3 bucket to store images and use the image link from this bucket in `vm_user_data_lt.sh` and `vm_user_data.sh`.

6. **Run Security Scan:**
   - Run a security scan on each push request using `run_security_scan.sh`.

7. **Initialize Terraform:**
   - After configuring the bucket names, initialize Terraform using the following command:
     ```
     terraform init
     ```

8. **Plan and Apply Changes:**
   - Use the following commands to plan and apply changes:
     ```
     terraform plan
     terraform apply
     ```

9. **Access Private VM:**
   - Access the private VM and create a stress test to test the autoscaling and load balancer.

10. **Destroy Resources:**
    - After successful testing, destroy the resources using the following command:
      ```
      terraform destroy
      ```
