# Week 4 — Postgres and RDS

## Business Use Case
Create Amazon RDS Postgress for developers to use for the Cruddur web application in AWS.

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

### Shell Script to connect to DB

We want to be able to add or remove from the schema file so:

For things we commonly need to do we can create a new directory called `bin`

We'll create an new folder called `bin` to hold all our bash scripts.

Create a new folder `bin` in `backend-flask` and create 3 files called:
```sql
db-create
db-drop
db-schema-load
```
These files are going to run bash scripts so insert a shebang into the top line of the 3 files:
`#! /usr/bin/bash`

Lets test the scripts:

### Shell Script to Drop DB

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

### Shell Script to create DB
Do the same for `db-create` and run `./bin/db-create` or `source bin/db-create`
```sh
#! /usr/bin/bash

echo "db-create"

#cant connect to cruddur if its not created yet
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"
```
### Shell Script for Schema load
```sh
#! /usr/bin/bash

echo "db-schema-load"

schema_path="$(realpath .)/db/schema.sql"
echo $schema_path

psql $CONNECTION_URL cruddur < $schema_path
```
### Toggle between Local mode and Production mode
We will introduce `if else` statement.
```sh
#! /usr/bin/bash

#echo "== db-schema-load"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"
echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```
**NB:** For more info about color, Refer to the following [link](https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux)

### Create Tables for Users and Activities

[Postgres Create Tables](https://www.postgresql.org/docs/current/sql-createtable.html)

```sql
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;
```

```sql
CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text,
  handle text,
  cognito_user_id text,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

```sql
CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```
### Shell Script for db connect

Create a new file called `db-connect`
```sql
#! /usr/bin/bash

psql $CONNECTION_URL
```
#### Change permission
```sh
chmod 744 bin/db-connect
```

### Shell script for db seed

Create a new file in `db` called `seed.sql`

Create a new file in `bin` called `db-seed`
```sql
#! /usr/bin/bash
#echo "== db-seed-load"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"

echo $seed_path

if [ "$1" = "prod" ]; then
 echo "Running in production mode"
 URL=$PROD_CONNECTION_URL
else
 URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
```
**Insert the following code in `seed.sql`**
```sql
-- this file was manually created
INSERT INTO public.users (display_name, handle, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown' ,'MOCK'),
  ('Andrew Bayko', 'bayko' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )
  ```
 ### Let's see other available connections
 Create a new file in `bin` called `db-sessions`
 ```sh
 #! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```
#### Change permission
```sh
chmod 744 bin/db-sessions
```
> We could have idle connections left open by our Database Explorer extension, try disconnecting and checking again the sessions.

### Easily setup (reset) everything for DB
This script enables us to easily run our command from one script instead of multiple commands using the terminal.

Create a new file called `db-setup` in `bin` folder
```sh
#! /usr/bin/bash
-e # stop if it fails at any point

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"


bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```
#### Change permission
```sh
chmod 744 bin/db-setup
```
### Install driver for psql
Every language has a driver like videographics driver for windows.

This driver helps us connect to postgres to work with the software.

## Install Postgres Client

We need to set the env var for our backend-flask application:

```yml
  backend-flask:
    environment:
      CONNECTION_URL: "${CONNECTION_URL}"
```

https://www.psycopg.org/psycopg3/

We'll add the following to our `requirments.txt`

```
psycopg[binary]
psycopg[pool]
```

```
pip install -r requirements.txt
```

## DB Object and Connection Pool in backend

`lib/db.py`

```py
from psycopg_pool import ConnectionPool
import os

def query_wrap_object(template):
  sql = '''
  (SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
  {template}
  ) object_row);
  '''

def query_wrap_array(template):
  sql = '''
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  '''

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)
```

In our `home activities.py` we'll replace our mock endpoint with real api call:

```py
from lib.db import pool, query_wrap_array

      sql = query_wrap_array("""
      SELECT
        activities.uuid,
        users.display_name,
        users.handle,
        activities.message,
        activities.replies_count,
        activities.reposts_count,
        activities.likes_count,
        activities.reply_to_activity_uuid,
        activities.expires_at,
        activities.created_at
      FROM public.activities
      LEFT JOIN public.users ON users.uuid = activities.user_uuid
      ORDER BY activities.created_at DESC
      """)
      print(sql)
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
          # this will return a tuple
          # the first field being the data
          json = cur.fetchone()
      return json[0]
```
In the `docker-compose` file, change the `CONNECTION_URL` to:
```sh
CONNECTION_URL: "postgresql://postgres:password@db:5432/cruddur"
```
## Connect to RDS via Gitpod
**Let us establish a connection to RDS Instance**

**NB: We have already created a `PROD_CONNECTION_URL` ENV VAR PREVIOUSLY AS WELL AS EXPORTED IT AS A GP ENV VAR**

When you try to connect to the RDS Instance from the terminal, it will hang because the sg for the instance cannot grant acces to gitpod.

In order to connect to the RDS instance we need to provide our Gitpod IP and whitelist for inbound traffic on port 5432.

```sh
export GITPOD_IP=$(curl ifconfig.me)
```
> Set as an ENV VAR for each access.

We'll create an inbound rule for Postgres (5432) and provide the GITPOD ID.

We'll get the security group rule id so we can easily modify it in the future from the terminal here in Gitpod.

Create the ENV VAR for the Security group and the Security group rule

```sh
export DB_SG_ID="sg-0de499e3ff47878c2"
gp env DB_SG_ID="sg-0de499e3ff47878c2"

export DB_SG_RULE_ID="sgr-0c149b46f0242a07f"
gp env DB_SG_RULE_ID="sgr-0c149b46f0242a07f"
```
Since the ip address changes everytime, you need to change the ip on the security group of the RDS instance.

Here is the script to add to the file rds-update-sg-rule under bin.
Whenever we need to update our security groups we can do this for access.
```sh
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

[AWS CLI Security Group Modify Rules](https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-security-group-rules.html#examples)

**We want this to take effect everytime we start up Gitpod.**

Create a new file `rds-update-sg-rule` in `bin` directory and paste the below code.
```sh
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```
#### Change permission
```sh
chmod 744 bin/rds-update-sg-rule
```
#### Update Gitpod.yml
Paste the below code into `gitpod.yml` so it automatically exports the Ip addr and executes the script.
```yml
  command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source  "$THEIA_WORKSPACE_ROOT/backend-flask/bin/rds-update-sg-rule"
 ```
 
 We have to load data into our production database.
 
 Go to `docker-compose.yml` and add ENV VAR to connect to prod. database
 ```yml
 CONNECTION_URL: "${PROD_CONNECTION_URL}"
 ```
 
 ### Implement Custom Authorizer for Cognito
 We need to have a `user` for activities and a `cognito_user_id`
 
 ### Setup Cognito post confirmation lambda
 ### Create the handler function

- Create a lambda function called `cruddur-post-confirmation` in same vpc as rds instance Python 3.8
- Create a new file in `aws/lambda` called `cruddur-post-confirmation.py`

The function

```import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)

    user_display_name  = user['name']
    user_email         = user['email']
    user_handle        = user['preferred_username']
    user_cognito_id    = user['sub']
    try:
      print('entered-try')
      sql = f"""
         INSERT INTO public.users (
          display_name, 
          email,
          handle, 
          cognito_user_id
          ) 
        VALUES(%s,%s,%s,%s)
      """
      print('SQL Statement ----')
      print(sql)
      conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
      cur = conn.cursor()
      params = [
        user_display_name,
        user_email,
        user_handle,
        user_cognito_id
      ]
      cur.execute(sql,params)
      conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
      print(error)
    finally:
      if conn is not None:
          cur.close()
          conn.close()
          print('Database connection closed.')
    return event
```
- **Paste the function in the lambda console.**
- In the Lambda console, go to `Configuration/Environment variables` and set env vars.
**NB:The env var is the `CONNECTION_URL` for PROD which was set in Gitpod.**

### Create Layer
- Create the layer>add layers.
- Select specify arn
```sh
arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py38:2
```
Add layer.

### Add Trigger
- Go to Cognito
- Select the user pool and go to User pool properties.
- Add lambda trigger.
- Set other configurations using the pictures below.

![lambda1](https://github.com/nielsen2e/aws-bootcamp-cruddur-2023/blob/main/journal/assets/lambda%201.png)
![lambda2](https://github.com/nielsen2e/aws-bootcamp-cruddur-2023/blob/main/journal/assets/lambda%202.png)
![lambda3](https://github.com/nielsen2e/aws-bootcamp-cruddur-2023/blob/main/journal/assets/lambda%203.png)

### Test Trigger
- Go and sign up in your application

`PostConfirmation failed with error local variable 'conn' referenced before assignment.`
An error about lambda.

### Go and check Cloud watch logs.

We saw that os was not defined so we imported it in the lambda function and deployed the new changes from the console.

We went to resend activitation code and we found a new error:

`User cannot be confirmed. Current status is CONFIRMED`

Now we have to delete our previously created user and sign up again.

`PostConfirmation failed with error 2023-04-17T10:49:50.847Z ed6e28d3-33fe-47a2-b556-eedee72bd9be Task timed out after 3.00 seconds.`

We have a new error.

This means its trying to connect to the postgress db and its running into issues.

We have a connection issue and after checking, the rds instance and lambda function have to be in the same vpc.

To connect to a vpc, go to Lambda configuration, click edit, pick default vpc
choose a subnet, make sure its the same subnet the rds instance is in.
put it in the default vpc security group.

When trying to save, there was a new error
`The provided execution role does not have permissions to call CreateNetworkInterface on EC2`

We need to set some permissions to enable the vpc give acces to the lambda function.

Go to configuration>permissions>click execution role>click add permissions>search for AWSLambdaVPCAccessExecutionRole

Add permissions.

After doing this, edit the vpc again.

The lambda function was triggered.

Connect to your rds database and check if the users were added.

![users](https://github.com/nielsen2e/aws-bootcamp-cruddur-2023/blob/main/journal/assets/Screenshot_20230417_125400.png)

The users were not added.

Check cloudwatch logs.

We have an error.

![cloudwatch](https://github.com/nielsen2e/aws-bootcamp-cruddur-2023/blob/main/journal/assets/Screenshot_20230417_125456.png)

**NB: Use the above edited lambda function to clear the error**

#### Create activities
Create new files `object.sql` and `create.sql` and `home.sql` in the `db/sql/activities`

In `object.sql`
```sql
SELECT
  activities.uuid,
  users.display_name,
  users.handle,
  activities.message,
  activities.created_at,
  activities.expires_at
FROM public.activities
INNER JOIN public.users ON users.uuid = activities.user_uuid 
WHERE 
  activities.uuid = %(uuid)s
```

In `create.sql`
```sql
INSERT INTO public.activities (
  user_uuid,
  message,
  expires_at
)
VALUES (
  (SELECT uuid 
    FROM public.users 
    WHERE users.handle = %(handle)s
    LIMIT 1
  ),
  %(message)s,
  %(expires_at)s
) RETURNING uuid;
```
In `home.sql`
```sql
SELECT
  activities.uuid,
  users.display_name,
  users.handle,
  activities.message,
  activities.replies_count,
  activities.reposts_count,
  activities.likes_count,
  activities.reply_to_activity_uuid,
  activities.expires_at,
  activities.created_at
FROM public.activities
LEFT JOIN public.users ON users.uuid = activities.user_uuid
ORDER BY activities.created_at DESC
```

Paste the folowwing code in `home_activities.py`
```py
from datetime import datetime, timedelta, timezone
from opentelemetry import trace

from lib.db import db

#tracer = trace.get_tracer("home.activities")

class HomeActivities:
  def run(cognito_user_id=None):
    #logger.info("HomeActivities")
    #with tracer.start_as_current_span("home-activites-mock-data"):
    #  span = trace.get_current_span()
    #  now = datetime.now(timezone.utc).astimezone()
    #  span.set_attribute("app.now", now.isoformat())
    sql = db.template('activities','home')
    results = db.query_array_json(sql)
    return results
```
In `create_activity.py`
```py
from datetime import datetime, timedelta, timezone

from lib.db import db

class CreateActivity:
  def run(message, user_handle, ttl):
    model = {
      'errors': None,
      'data': None
    }

    now = datetime.now(timezone.utc).astimezone()

    if (ttl == '30-days'):
      ttl_offset = timedelta(days=30) 
    elif (ttl == '7-days'):
      ttl_offset = timedelta(days=7) 
    elif (ttl == '3-days'):
      ttl_offset = timedelta(days=3) 
    elif (ttl == '1-day'):
      ttl_offset = timedelta(days=1) 
    elif (ttl == '12-hours'):
      ttl_offset = timedelta(hours=12) 
    elif (ttl == '3-hours'):
      ttl_offset = timedelta(hours=3) 
    elif (ttl == '1-hour'):
      ttl_offset = timedelta(hours=1) 
    else:
      model['errors'] = ['ttl_blank']

    if user_handle == None or len(user_handle) < 1:
      model['errors'] = ['user_handle_blank']

    if message == None or len(message) < 1:
      model['errors'] = ['message_blank'] 
    elif len(message) > 280:
      model['errors'] = ['message_exceed_max_chars'] 

    if model['errors']:
      model['data'] = {
        'handle':  user_handle,
        'message': message
      }   
    else:
      expires_at = (now + ttl_offset)
      uuid = CreateActivity.create_activity(user_handle,message,expires_at)

      object_json = CreateActivity.query_object_activity(uuid)
      model['data'] = object_json
    return model

  def create_activity(handle, message, expires_at):
    sql = db.template('activities','create')
    uuid = db.query_commit(sql,{
      'handle': handle,
      'message': message,
      'expires_at': expires_at
    })
    return uuid
  def query_object_activity(uuid):
    sql = db.template('activities','object')
    return db.query_object_json(sql,{
      'uuid': uuid
    })
```
