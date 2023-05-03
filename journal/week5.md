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


## # Data Modelling
For the messaging part, we will implement a single table data modelling using Dynamo DB. Below you will see the pattern for CRUDDUR

1. **Pattern A**: Shows the messages. Users can see the list of the messages that belong to a message group.
2. **Pattern B**: Shows the message group conversation with a specific user.
3. **Pattern C**: Create a new message in a new message group.
4. **Pattern D**: Create a new message in an exisintg group.

## Pattern A (showing a single conversation)

A user wants to see a list of messages that belong to a message group
The messages must be ordered by the created_at timestamp from newest to oldest (DESC)

```sql
SELECT
  messages.uuid,
  messages.display_name,
  messages.message,
  messages.handle,
  messages.created_at -- sk
FROM messages
WHERE
  messages.message_group_uuid = {{message_group_uuid}} -- pk
ORDER BY messages.created_at DESC
```

> message_group_uuid comes from Pattern B

## Pattern B (list of conversation)

A user wants to see a list of previous conversations.
These conversations are listed from newest to oldest (DESC)
We want to see the other person we are talking to.
We want to see the last message (from whomever) in summary.

```sql
SELECT
  message_groups.uuid,
  message_groups.other_user_uuid,
  message_groups.other_user_display_name,
  message_groups.other_user_handle,
  message_groups.last_message,
  message_groups.last_message_at
FROM message_groups
WHERE
  message_groups.user_uuid = {{user_uuid}} --pk
ORDER BY message_groups.last_message_at DESC
```

> We need a Global Secondary Index (GSI)

## Pattern C (create a message)

```sql
INSERT INTO messages (
  user_uuid,
  display_name,
  handle,
  creaed_at
)
VALUES (
  {{user_uuid}},
  {{display_name}},
  {{handle}},
  {{created_at}}
);
```

## Pattern D (update a message_group for the last message)

When a user creates a message we need to update the conversation
to display the last message information for the conversation

```sql
UPDATE message_groups
SET 
  other_user_uuid = {{other_user_uuid}}
  other_user_display_name = {{other_user_display_name}}
  other_user_handle = {{other_user_handle}}
  last_message = {{last_message}}
  last_message_at = {{last_message_at}}
WHERE 
  message_groups.uuid = {{message_group_uuid}}
  AND message_groups.user_uuid = {{user_uuid}}
```

![Pattern](https://github.com/dontworryjohn/aws-bootcamp-cruddur-2023/blob/main/images/message%20pattern.jpeg)



