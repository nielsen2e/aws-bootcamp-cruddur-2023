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
## Run Flask(**Locally**)

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
