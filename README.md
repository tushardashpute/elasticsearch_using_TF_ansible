# elasticsearch_using_TF_ansible
Setup elasticSearch on EC2 instances using TF and ansible

Steps:
1. Create a EC2 instance
2. Install the ansbile and Terraform on the same host
3. For the TF authentication create a role and assign the required access policies to that role and assign it to the EC2 instance
4. Execute the ec2_setup.tf  [Update the key_name , have used the us-east-1 as the default region]
 
 - terraform init
 - terraform plan
 - terraform apply

This will create the ec2 instance of t2.micro type and install the elasticsearch and start it as well with the cutom password which we have provided.
