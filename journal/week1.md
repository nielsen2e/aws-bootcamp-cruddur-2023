# Week 1 — App Containerization

## Why Containerize?
1. We containerize our apps to make it portable and also ensure lack of documentation of application and OS configuration.
2. To ensure you don't destroy your environment when doing testing.
3. To avoid having different variants of OS and enable you replicate the container environments in different workspaces and
   not have to worry about each user's different requirements.

## Containerize Backend
Create a Docker file here:  `backend-flask/Dockerfile`

```dockerfile
FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```
### Run Flask(**Locally**)

```sh
cd backend-flask
export FRONTEND_URL="*"
export BACKEND_URL="*"
python3 -m flask run --host=0.0.0.0 --port=4567
cd ..
```

> This script configures environment variables to get our endpoint working.

 [Endpoint](https://4567-nielsen2e-awsbootcampcr-afx5p2tp8vw.ws-eu89.gitpod.io/api/activities/home)
 
- make sure to unlock the port on the port tab
- open the link for 4567 in your browser

> unset env vars
- `unset BACKEND_URL`
- `unset FRONTEND_URL`

### Build container
```
docker build -t  backend-flask ./backend-flask
```
### Run container
```
docker run --rm -p 4567:4567 -it backend-flask
```
### Run container and set env vars
```
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
```
## Containerize Frontend
Create a Dockerfile here: `frontend-react-js/Dockerfile`

```dockerfile
FROM node:16.18

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```
### Run Container
```
docker run -p 3000:3000 -d frontend-react-js
```
## Creating Multiple Containers
### Create a **docker-compose** file at the root of the project
- Docker-compose file allows us to run multiple containes at the same time.
  - Using docker-compose allows us orchestrate multiple containers that have to work together locally.
```yml
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```
## Adding Dynamo DB local and Postgres
We are going to add Dynamo db and Postgres services to our docker compose file.
### Dynamo DB
```yml
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
```
### Postgres
```yml
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
```
### To install postgres client into gitpod
```sh
  - name: postgres
    init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev
```
## Volumes
- This should be added after networks
  - Directory volume mapping
```yml
volumes: 
- "./docker/dynamodb:/home/dynamodblocal/data"
```
   - Named volume mapping
```yml
volumes: 
  - db:/var/lib/postgresql/data

volumes:
  db:
    driver: local
```
  


