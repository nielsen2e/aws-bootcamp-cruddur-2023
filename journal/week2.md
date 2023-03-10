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

## Known issues:
- Running docker-compose up using the left click didn't export the API key because it created a new shell and gitpod didn't
  export the key to the container. It happend sometimes.
