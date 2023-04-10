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

### Provision RDS instance
```yml
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username root \
  --master-user-password huEE33z2Qvl3834 \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
  ```
  
  **NB: You can stop your db instance temporarily for 7 days**
  
  ### Connect to Postgres
  There are 2 ways to connect to Postgres:
  - Using the psql client
  - Using the database explorer.
 
**NB: To connect to psql via the psql client cli tool remember to use the host flag to specific localhost.**

`psql -Upostgres --host localhost`

## Common PSQL commands
```sql
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```

## Create Databse using psql client
```sql
CREATE database cruddur;
```
### Create Tables
We need to create a schema for our db which will serve as a structure for our data.
Go to `backend-flask` and create a folder called db and a file caled `schema.sql`

### Add UUID Extension
UUID - Universally Unique Identifier generates a big strng or number that ranadoms which eliminates conflicts and helps us obscure our number count.
```sql
CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```
Add the 2nd option to `schema.sql`

Exit postgres and import script:
`psql cruddur < backend-flask/db/schema.sql -h localhost -U postgres`

## Create Env Vars for Connection Url String
Instead of typing password eveyrtime we log in to postgres, we can use a **connection Url String** which is a way of providing all the details that it needs to authenticate to the server.

**Connection url string format:**

`postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]`

```var
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```
Run `psql CONNECTION_URL` TO LOGIN.

Now you can sign it to postgress without entering password.

## Create Connection Url String for AWS RDS Instance

`export PROD_CONNECTION_URL="postgresql://cruddurroot:huEE33z2Qvl3834@cruddur-db-instance.cdan7agqzige.us-east-1.rds.amazonaws.com:5432/cruddur"`

`gp env PROD_CONNECTION_URL="postgresql://cruddurroot:huEE33z2Qvl3834@cruddur-db-instance.cdan7agqzige.us-east-1.rds.amazonaws.com:5432/cruddur"`
> Test Later

We want to be able to adding or removing from the schema file so:

Create a new folder `bin` in `backend-flask` and create 3 files called:
```sql
db-create
db-drop
db-schema-load
```
These files are going to run bash scripts so insert a shebang into the top line of the 3 files:
`#! /usr/bin/bash`

Lets test the scripts:

Go into `db-drop` and type `psql $CONNECTION_URL -c "drop database cruddur;"`

Make the files executable:
```bash
chmod 744 bin/db-create
chmod 744 bin/db-drop
chmod 744 bin/db-schema-load
```

We are trying to drop our db `cruddur` while logging in to postgress but its not working so we need to use a tool called `sed` to edit the string.

`NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")`

Now edit the file `db-drop` with the code below and run `./bin/db-drop`
```sh
#! /usr/bin/bash

echo "db-drop"
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "drop database cruddur;"
```

Do the same for `db-create`
`db-create` file
```sh
#! /usr/bin/bash

echo "db-create"

#cant connect to cruddur if its not created yet
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"
```


