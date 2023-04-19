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

## DynamoDB Pricing
DynamoDB charges for `reading, writing, and storing data in your DynamoDB tables`, along with any optional features you choose to enable. DynamoDB has two capacity modes, which come with specific billing options for processing reads and writes on your tables: on-demand and provisioned.

There are two pricing options available for Amazon DynamoDB: `on-demand capacity mode` and `provisioned capacity mode`. With two pricing models, DynamoDB allows you to choose the best pricing option for your workload.

## Pricing for on-demand capacity mode

With on-demand capacity mode, DynamoDB charges you for the data reads and writes your application performs on your tables. You can get started without specifying read or write capacity as DynamoDB will instantly adjust based on your workloads’ requirements

`On-demand capacity mode` might be best if you:

- Create new tables with unknown workloads
- Have unpredictable application traffic
- Prefer the ease of paying for only what you use

## Pricing for provisioned capacity mode
With provisioned capacity mode, you specify the number of reads and writes per second that you expect your application to require. You can use auto scaling to automatically adjust your table’s capacity based on the specified utilization rate to ensure application performance while reducing costs.

`Provisioned capacity mode` might be best if you:

- Have predictable application traffic
- Run applications whose traffic is consistent or ramps gradually
- Can forecast capacity requirements to control costs

## DynamoDB Pricing Figures

### Free Forever Tier
- 25 GB of Storage
- 25 provisioned Write Capacity Units (WCU)
- 25 provisioned Read Capacity Units (RCU)
- Enough to handle up to 200M requests per month.


## Momento Pricing

### Free Tier
- First 50GB transferred to/from Momento per month Beyond Free Tier
- $0.15 per GB

[Momento Pricing](https://www.gomomento.com/pricing)





