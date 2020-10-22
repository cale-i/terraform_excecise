# Terraform Excercise

* WebServer + DB 用の冗長構成

# 構成

* VPC
* Multi-Avairability-Zone
    * ap-northeast-1a
        * Public Subnet
            * EC2 Instance
        * private Subnet
            * RDS Master
    * ap-northeast-1c
        * Public Subnet
            * EC2 Instance
        * private Subnet
            * RDS Slave
* ELB(ALB)


# Requirement

* Python 3.8.5
* Terraform v0.13.4
* aws-cli/2.0.56 Python/3.7.7 Windows/10 exe/AMD64
