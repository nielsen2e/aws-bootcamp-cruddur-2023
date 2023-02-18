# Week 0 — Billing and Architecture

# Required Homework

## Recreating Cruddur Logical Architecture

I recreated the Cruddur Logical diagram. 

Here is a screenshot.

![Logical diagram](assets/Cruddur%20Logicall%20Diagram.png)

Still could make it better but its a work in progress.

Here is further proof

[Cruddur Logical Diagram](https://lucid.app/lucidchart/72ad9a9b-621a-4c78-9fa9-84d37990deed/edit?viewport_loc=-837%2C623%2C2684%2C1146%2C0_0&invitationId=inv_f57dc6c3-a22c-4620-afd5-7e9e7d60f05a)

## Creating Conceptual Napkin diagram

I drew a conceptual diagram on a napkin.

![Napkin Diagram](assets/20230218_090601.jpg)

Heres a little note on the **components** of the diagram:

- **User Data:** This component represents the information about the users of the Cruddur app, such as their profile data, tweets, followers and other relevant information.

- **Frontend:** This component represents the user interface of the Cruddur app, which users interact with on their mobile devices or web browsers. The frontend handles user input, communicates with the backend, and displays data to the user.

- **Backend API:** This component provides a RESTful API for the frontend to interact with the backend. The API handles incoming requests, communicates with the data service, and sends responses back to the frontend.

- **Mobile App:** This component represents the obile version of the twitter app, which is optimized for use on smartphones and tablets.

- **Web App:** This component represents the web version of the Twitter app, which is optimized for us on desktop and laptop computers.

- **Data Servic:** This component manages the data for the twitter app, which included user data, tweets and oter relevant information, The data service communicates with the database to store and retrieve data.

- **Database:** This component represents the database where the user data, tweets, and other relevant information are stored.

### Install AWS CLI

- I installed the AWS CLI using gitpod.
- I set AWS CLI to use partial autoprompt mode to make it easier to debug CLI commands.
- The bash commands I used can also be found at [AWS CLI Install Instructions]https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Update our `.gitpod.yml` to include the following task.

```sh
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```
![AWS CLI](assets/Screenshot_20230218_120048.png)

## Creating a Billing Alarm

### Create SNS Topic

- We need an SNS topic before we create an alarm.
- The SNS topic is what will delivery us an alert when we get overbilled
- [aws sns create-topic](https://docs.aws.amazon.com/cli/latest/reference/sns/create-topic.html)

I created an SNS Topic
```sh
aws sns create-topic --name billing-alarm
```
which  returned a TopicARN

I created a subscription to apply the TopicARN and my Email
```sh
aws sns subscribe \
    --topic-arn TopicARN \
    --protocol email \
    --notification-endpoint danielamadi000@email.com
```

#### Create Alarm

- [aws cloudwatch put-metric-alarm](https://docs.aws.amazon.com/cli/latest/reference/cloudwatch/put-metric-alarm.html)
- [Create an Alarm via AWS CLI](https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-estimatedcharges-alarm/)
- We need to update the configuration json script with the TopicARN we generated earlier
- We are just a json file because --metrics is is required for expressions and so its easier to us a JSON file.

```sh
aws cloudwatch put-metric-alarm --cli-input-json file://aws/json/alarm_config.json
```

## Create an AWS Budget

[aws budgets create-budget](https://docs.aws.amazon.com/cli/latest/reference/budgets/create-budget.html)

```sh
aws budgets create-budget \
    --account-id AccountID \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/budget-notifications-with-subscribers.json
```

## Homework Challenges

### Research the technical and service limits of specific AWS  services and how they could impact the technical path for technical flexibility.

- **Amazon EC2 Instance Types:** Amazon Elastic Compute Cloud (EC2) provides a wide range of instance types to support various workloads. Each instance type has its own set of technical specifications, such as CPU, memory, and storage capacity. However, some of these instance types have service limits that could impact technical flexibility. For example, the T2 instance type has a CPU credit balance that can limit the number of CPU cycles available to the application. This could impact the performance of the application and limit technical flexibility.

- **Amazon S3 Storage Classes:** Amazon Simple Storage Service (S3) provides various storage classes to support different data access patterns. Each storage class has its own set of technical specifications, such as availability and durability. However, some of these storage classes have service limits that could impact technical flexibility. For example, the Glacier storage class has a minimum storage duration of 90 days, which could impact the ability to access data quickly and limit technical flexibility.

- **Amazon RDS Database Engines:** Amazon Relational Database Service (RDS) provides various database engines to support different workloads. Each database engine has its own set of technical specifications, such as performance and scalability. However, some of these database engines have service limits that could impact technical flexibility. For example, the Aurora database engine has a maximum of 15 read replicas per instance, which could limit the ability to scale the database and impact technical flexibility.

- **AWS Lambda Function Limits:** AWS Lambda provides serverless computing capabilities to run code without provisioning or managing servers. However, Lambda has some service limits that could impact technical flexibility. For example, Lambda has a maximum execution time limit of 15 minutes, which could limit the ability to run long-running processes and impact technical flexibility.

- **Amazon DynamoDB Limits:** Amazon DynamoDB is a NoSQL database service that provides fast and flexible data storage. However, DynamoDB has some service limits that could impact technical flexibility. For example, DynamoDB has a limit of 400 KB per item, which could impact the ability to store large data items and limit technical flexibility.

**In general, service limits could impact technical flexibility by limiting the ability to scale, perform, and store data. When designing applications on AWS, it is important to consider service limits and choose the appropriate AWS services and configurations to meet the technical requirements of the application. Additionally, it is important to monitor service limits and adjust the application architecture as needed to maintain technical flexibility.**



