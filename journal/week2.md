# Week 2 — Distributed Tracing
Distributed tracing is a technique used in software engineering to track and analyze the flow of requests through complex distributed systems. A distributed system is one in which multiple independent components, such as microservices, interact with each other to accomplish a common goal.

In a distributed tracing system, each request is assigned a unique identifier, and this identifier is passed along with the request as it flows through the various components of the system. Each component then logs information about the request and its processing, including any errors or delays encountered, and passes this information along to the next component in the chain.

The result is a trace that shows the complete path of the request through the system, including all the individual components it passed through and the time it spent at each one. This information can be used to identify performance bottlenecks, diagnose errors, and optimize the overall performance of the system.

Distributed tracing is particularly useful in modern, cloud-based environments where applications are composed of many small, interconnected components. By providing visibility into the interactions between these components, distributed tracing helps developers and operators to quickly pinpoint and resolve issues, leading to improved system reliability and faster time-to-resolution.

## HoneyComb
Honeycomb is a cloud-based observability and monitoring tool that helps software teams gain insights into the behavior of their applications and systems. It is designed to provide high-fidelity, real-time visibility into distributed systems, allowing users to quickly identify and diagnose issues.

At its core, Honeycomb uses a distributed tracing approach to collect data about application requests as they move through a system. This data is then combined with other sources of information, such as metrics and logs, to provide a complete picture of system behavior.

One of the key features of Honeycomb is its query language, which allows users to slice and dice their data in a variety of ways, enabling them to explore complex system behaviors and identify patterns that might be missed using other monitoring tools. The query language is designed to be intuitive and easy to use, with features such as autocomplete and built-in functions to simplify the process of constructing queries.

### Pre-requesites
- Create honeycomb account: [honeycomb](www.honeycomb.io)
- Get the API key from your honeycomb account.
```sh
export HONEYCOMB_API_KEY=""
export HONEYCOMB_SERVICE_NAME="Cruddur"
gp env HONEYCOMB_API_KEY=""
gp env HONEYCOMB_SERVICE_NAME="Cruddur"
```
**NB:**
- Make sure to use export before using gp env
- We use gp env to persist the data

## Install Packages
Install these packages to instrument a Flask app with OpenTelemetry:
### Add the following packages to `requirements.txt` in `/backend-flask`

```yml
    opentelemetry-api 
    opentelemetry-sdk 
    opentelemetry-exporter-otlp-proto-http 
    opentelemetry-instrumentation-flask 
    opentelemetry-instrumentation-requests
```

### Install these dependencies in the `backend-flask` directory:

```py
pip install -r requirements.txt
```

 ### Initialize
Add these lines to your existing Flask app initialization file app.py (or similar). These updates will create and initialize a tracer and Flask instrumentation to send data to Honeycomb:
```py
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
```


```py
# Initialize tracing and an exporter that can send data to Honeycomb
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
```

```py
# Initialize automatic instrumentation with Flask
app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
```

### Add the following Env Vars to `backend-flask` in docker compose

```yml
OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
OTEL_SERVICE_NAME: "${HONEYCOMB_SERVICE_NAME}"
```
### Instructions
- cd frontend-react-js
- npm i
- cd ..
- docker compose up

### Known issues:
- Running docker-compose up using the left click didn't export the API key because it created a new shell and gitpod didn't
  export the key to the container. It happend sometimes.
  
## AWS X-RAY
AWS X-Ray is a service offered by Amazon Web Services (AWS) that helps developers analyze and debug distributed applications, such as those built using microservices architecture. With X-Ray, developers can trace requests made to their application as they travel through different microservices, and can visualize the dependencies between those microservices.

X-Ray provides a variety of tools and features to help developers debug their applications, including:

**Tracing:** X-Ray provides a tracing API that developers can use to instrument their application code and capture data about requests as they move through the application.

**Service map:** X-Ray generates a service map that shows the dependencies between the different microservices in an application. This can help developers identify bottlenecks and areas for optimization.

**Insights:** X-Ray provides a dashboard that displays information about the performance of an application, including error rates, response times, and throughput.

**Integration:** X-Ray integrates with a variety of AWS services, including EC2, Lambda, and Elastic Beanstalk, as well as with popular third-party tools like Kubernetes and Istio.

### Instrument AWS X-Ray for Flask


```sh
export AWS_REGION="us-east-1"
gp env AWS_REGION="us-east-1"
```

Add to the `requirements.txt`

```py
aws-xray-sdk
```

Install pythonpendencies

```sh
pip install -r requirements.txt
```

Add to `app.py`

```py
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

xray_url = os.getenv("AWS_XRAY_URL")
xray_recorder.configure(service='Cruddur', dynamic_naming=xray_url)
XRayMiddleware(app, xray_recorder)
```

### Setup AWS X-Ray Resources

Add `aws/json/xray.json`

```json
{
  "SamplingRule": {
      "RuleName": "Cruddur",
      "ResourceARN": "*",
      "Priority": 9000,
      "FixedRate": 0.1,
      "ReservoirSize": 5,
      "ServiceName": "Cruddur",
      "ServiceType": "*",
      "Host": "*",
      "HTTPMethod": "*",
      "URLPath": "*",
      "Version": 1
  }
}
```

```sh
FLASK_ADDRESS="https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"backend-flask\")"
```

```sh
aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json
```

 [Install X-ray Daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html)

[Github aws-xray-daemon](https://github.com/aws/aws-xray-daemon)
[X-Ray Docker Compose example](https://github.com/marjamis/xray/blob/master/docker-compose.yml)


```sh
 wget https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.deb
 sudo dpkg -i **.deb
 ```

### Add Deamon Service to Docker Compose

```yml
  xray-daemon:
    image: "amazon/aws-xray-daemon"
    environment:
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "us-east-1"
    command:
      - "xray -o -b xray-daemon:2000"
    ports:
      - 2000:2000/udp
```

We need to add these two env vars to our backend-flask in our `docker-compose.yml` file

```yml
      AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
      AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```

### Check service data for last 10 minutes

```sh
EPOCH=$(date +%s)
aws xray get-service-graph --start-time $(($EPOCH-600)) --end-time $EPOCH
```

## CloudWatch Logs


Add to the `requirements.txt`

```
watchtower
```

```sh
pip install -r requirements.txt
```


In `app.py`

```
import watchtower
import logging
from time import strftime
```

```py
# Configuring Logger to Use CloudWatch
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
cw_handler = watchtower.CloudWatchLogHandler(log_group='cruddur')
LOGGER.addHandler(console_handler)
LOGGER.addHandler(cw_handler)
LOGGER.info("some message")
```

```py
@app.after_request
def after_request(response):
    timestamp = strftime('[%Y-%b-%d %H:%M]')
    LOGGER.error('%s %s %s %s %s %s', timestamp, request.remote_addr, request.method, request.scheme, request.full_path, response.status)
    return response
```

We'll log something in an API endpoint
```py
LOGGER.info('Hello Cloudwatch! from  /api/activities/home')
```

Set the env var in your backend-flask for `docker-compose.yml`

```yml
      AWS_DEFAULT_REGION: "${AWS_DEFAULT_REGION}"
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
```

> passing AWS_REGION doesn't seems to get picked up by boto3 so pass default region instead


## Rollbar

https://rollbar.com/

Create a new project in Rollbar called `Cruddur`

Add to `requirements.txt`


```
blinker
rollbar
```

Install deps

```sh
pip install -r requirements.txt
```

We need to set our access token

```sh
export ROLLBAR_ACCESS_TOKEN=""
gp env ROLLBAR_ACCESS_TOKEN=""
```

Add to backend-flask for `docker-compose.yml`

```yml
ROLLBAR_ACCESS_TOKEN: "${ROLLBAR_ACCESS_TOKEN}"
```

Import for Rollbar

```py
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception
```

```py
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
@app.before_first_request
def init_rollbar():
    """init rollbar module"""
    rollbar.init(
        # access token
        rollbar_access_token,
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app)
```

We'll add an endpoint just for testing rollbar to `app.py`

```py
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
```


![Rollbar](/journal/assets/Screenshot_20230328_012637.png)
