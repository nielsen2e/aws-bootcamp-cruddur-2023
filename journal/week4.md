# Week 4 — Postgres and RDS

## Business Use Case
Create Amazon RDS Postgress for deveopers to use fot the Cruddur web application in AWS.

## Amazon RDS
Amazon RDS (Relational Database Service) is a cloud-based database service provided by Amazon Web Services (AWS). It allows users to create and manage relational databases in the cloud using various database engines, including MySQL, PostgreSQL, Oracle, SQL Server, and MariaDB.

**NB: We will be using `Postgres RDS` for our application.**

### Security Best Practices - AWS
1. Use VPCs: Use Amazon Virtual Private Cloud (VPC) to create a private network for your RDS instance. This helps prevent unauthorized access to your instance from the public internet.
2. Compliance standard is what your business requires.
3. RDS instances should only be in the AWS  region that you are legally allowed to be holding user data in.
4. Amazon Organizations SCP - to manage RDS deletion, RDS crearion, region lock, RDS Encryption enforced etc.
5. AWS Cloudtrail is enabled & monitored to trigger alerts on malicious RDS behaviour by and indentity on AWS.
6. Amazon Guardduty is enabled in the account and region of RDS.

### Security Best Practices - Application(Developer)
1. RDS instance to use appropriate Auhencitcation - Use IAM authentication, kerberos etc (not the default)
2. Database User Lifecycle Management - Create, Modify, Delete Users
3. AWS User Access Lifecycle Management - Change of Roles/Revoke Roles etc
4. Security Group to be restricted only to known IPs
5. Not have RDS be internet accessible
6. Encryption in Transt for comms between App and RDS
7. Secret Management: Master User passwords can be used with AWS Secrets Manager to automatically rotate the secrets for AMazon RDS
