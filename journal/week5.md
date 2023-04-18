# Week 5 — DynamoDB and Serverless Caching

## Business Use Case
Create Amazon DynamoDB for Cruddur Web Application.

## Amazon DynamoDB
Amazon DynamoDB is a fully managed NoSQL database service provided by Amazon Web Services (AWS). It allows developers to create and manage high-performance, scalable, and reliable databases without the need for manual setup or administration.

DynamoDB is designed to handle large volumes of data and high levels of request traffic with low latency. It provides automatic scaling and replication of data across multiple Availability Zones to ensure high availability and fault tolerance.

DynamoDB supports a flexible data model, allowing users to store and retrieve data in any format and index it using primary and secondary indexes. It also supports transactions, which enable developers to perform multiple operations on a set of items as a single, atomic unit of work.

DynamoDB offers various features such as backup and restore, in-memory caching, global tables, and streams for real-time data processing. It also integrates with other AWS services such as Lambda, CloudFormation, and CloudTrail for automated deployment, monitoring, and auditing.

## Security Best Practices - AWS
1. Use VPC Endpoints: Use Amazon Virtual Private Cloud (VPC) to create a private network from your application or Lambda to a DynamoDB. This helps
prevent unauthorized access to your instance from the public internet.
2. Compliance standard is what your business requires.
3. Amazon DynamoDB should only be in the AWS region that you are legally alllowed to be holding user data in.
4. Amazon Organizations SCP - ro manage DynamoDB Table deletion,  DynamoDB creation, region lock etc.
5. AWS CloudTrail is enabled & monitored to trigger alerts on malicious DynamoDB behaviour by an identity in AWS.
6. AWS Config Rules ( as no GuardDuty even in Mar 2023) is enabled in the account and region of DynamoDB 

## Security Best Practices - Application
1. DynamoDB to use appropriate Authentication - Use IAM Roles/AWS Cognito Identity Pool - Avoid IAM Users/Groups.
2. DynamDB User Lifecycle Management - Create, Modify, Delete Users.
3. AWS IAM Roles instead of individual users to access and manage DynamoDB.
4. DAX Service (IAM) Role to have Read Only Access to DynamoDB (if possile).
5. Not have DynamoDB be accessed from the internet (use VPC Endpoints etc).
6. Site to Site VPN or direct Connect for Onpremise and DynamoDB Access.
7. Client side encryption is recommended by Amazon for DynamoDB.
