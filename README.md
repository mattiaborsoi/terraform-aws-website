 ![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.13-blue.svg)

# Description
 Spins up a web server on AWS using Terraform.

 ### Changelog
 - added HTTPS configuration for Apache and deployment of SSL certificates
 - Website source code downloaded from [github/mattiaborsoi/public-website](https://github.com/mattiaborsoi/public-website)

 # Setup

 1. Install [Terraform](https://www.terraform.io/). You can also use https://brew.sh/ to install Brew, and then launch `brew install terraform`
1. Setup the AWS credentials
```
mkdir ~/.aws
nano ~/.aws/credentials-terraform
```
Create a credentials file in the following format:
```
[default]
aws_access_key_id = yourAccessKeyHere
aws_secret_access_key = yourSecretKeyHere
```
 You can set the file’s permissions to make sure that only the owner is allowed to access the file.
 ```
chmod 600 ~/.aws/credentials-terraform
```

Create a keypair on AWS EC2 for your region. For the demo I used eu-west-2 (London) so the URL is https://eu-west-2.console.aws.amazon.com/ec2/v2/home?KeyPairs:&region=eu-west-2#KeyPairs:

Use **name=terraform**, **format=pem**
Save the downloaded .pem file in ~/.aws/terraform.pem

For additional security of the credentials file, your key must not be publicly viewable for SSH to work. Use this command if needed:
```
chmod 400 ~/.aws/terraform.pem 
```
**Important:**
>Rename the file `terraform.tfvars.default` to `terraform.tfvars` and change the variables accordingly.
(The terraform.tfvars file is in .gitignore as it contains sensitive data)

Head to https://s3.console.aws.amazon.com/s3/home and **Create a bucket**. I'm calling it `terraform-website-state`, based in Region eu-west-2, select Block all public access, enable versioning and enable Server-side encryption.


Run terraform
```
terraform init
terraform apply -lock=false 
```
We are using -lock=false as the lock file won't exist on the DB on the first run.


If needed, connect to your instance using its public IP (which terraform apply should have sent in output):
```
ssh -i "~/.aws/terraform.pem" ubuntu@<your_instance IP>
```

**Note:**
Your webserver IP will be shown on Terminal as an output variable. You can change your domain A record to be forwarded to that IP.
In my script I'm actually automating this using Cloudflare.
Plus I'm using SSL certificates, so you will need to change those to make it work for your domain. Ping me if you need help.



## Don't forget!
Billing for your server(s) will continue until you destroy the project. To terminate all instances, in Terminal. run `terraform destroy`.

## To do:
- allow SSH in the server from my local IP address
- setup a load balancer with 1 micro instance running and auto resize if needed