# Week 3 — Decentralized Authentication
Decentralized authentication is a method of authentication that involves using a decentralized network instead of a centralized authority to verify user identity. This approach is often used in blockchain technology, where the decentralized network is composed of nodes that all share a copy of the blockchain.

In decentralized authentication, users typically create an identity that is linked to a specific public key. When they attempt to access a resource, they must provide proof of ownership of the associated private key, which can be verified by the decentralized network.

## Advantages of Decentalized AuthN over Traditonal Centralized AuthN
1. it is more secure because it eliminates the need for a central authority to store sensitive user data that could be vulnerable to hacks or breaches. 
2. it can be more transparent and user-controlled because users can manage their own identity and access to resources on the network.

In AWS, we have the:
- Amazon side
- Client Application Side

In the Amazon side, we have access to amazon console to create a userpool and add clients while in the Client Side, this involves interacting with Amazon Cognito
to authorize users to access information.

## Amazon Cognito
Amazon Cognito is a cloud-based service provided by Amazon Web Services (AWS) that provides user authentication, authorization, and user management capabilities for mobile and web applications. It allows developers to add user sign-up, sign-in, and access control to their applications, as well as manage user data, such as user profiles and app settings.

Cognito provides two main features: **User Pools and Identity Pools**.

**User Pools** allows developers to manage user authentication and authorization for their applications, including sign-up, sign-in, and multi-factor authentication.

**Identity Pools**, on the other hand, allows developers to securely access AWS services and resources on behalf of their users, by providing temporary AWS credentials.

## Why use Amazon Cognito?
- Ability to access AWS Resources for the application being built.
- Identity broker for AWS Resources wit temporary credentials.
- Can extend users to AWS Resources easily.

## Amazon Cognito Security Best Practices - AWS
1. AWS Services - API Gateway, AWS Resouces shared with the application Client (Bakcend or back channels)
2. AWS WAF with web ACLs for rate limirting, Allow/Dent list, Deny Access from region and many more WAF management rules similar to OWASP(market place)
3. Amazon Cognito compliance standard is what your business requires.
4. Amazon Cognito should only be in the AWS region that you are legally allowed to be holding user data in.
5. Amazon Organizations SCP - to manage user pool deletion, creation, region lock etc.
6. AWS Cloudtrail is enabled and monitored to trigger alerts on malicious cognito behaviour by an indentity in AWS.

## Amazon Cognito Security Best Practices - Application
1. Application should use an industry standard for AuthN and AuthZ(SAML, OpenID Connect, OAuth2.0 etc)
2. Application user lifecycle management -Create, Modify, Delete Users.
3. AWS User Access lifecycle Mnagament - Change of Roles/Revoke roles etc.
4. Role based Access to manage how much access to AWS Resources for the application being built.
5. Token lifecycle Management - Issue new tokens, revoke compromised tokens where to store (Client/server).
6. Security tests of the application through penetration testing.
7. Access Token scope - should be limited.
8. JWT Token best practice - no sensitive info.
9. Encryotion in Transit for API calls.


## Cost
The Cognito Your User Pool feature has a free tier of 50,000 MAUs ( monthly active users) per account for users who sign in directly to Cognito User Pools and 50 MAUs for users federated through SAML 2.0 based identity providers. The free tier does not automatically expire at the end of your 12 month AWS Free Tier term, and it is available to both existing and new AWS customers indefinitely. Please note - the free tier pricing isn’t available for both Your User Pool feature and SAML or OIDC federation in the AWS GovCloud regions.

For reference click [Here](https://aws.amazon.com/cognito/pricing/).

# Setup Cognito User Pool

Click [here](https://scribehow.com/shared/How_to_Create_a_User_Pool_in_AWS_Cognito__KfU7GrqHS2ex3SW-xNLcSw) to create the user pool using the AWS console

## AWS Amplify
AWS Amplify is a development platform and set of tools provided by Amazon Web Services (AWS) that allows developers to build and deploy cloud-powered mobile and web applications quickly and easily. It provides a variety of features and services, including hosting, authentication, data storage, and API integrations.

One of the key features of AWS Amplify is its ability to simplify the development process by providing pre-built components and libraries that can be easily integrated into an application. These components include user authentication, real-time data synchronization, push notifications, and more.

## Configure AWS Amplify
```
cd frontend-react-js
npm i aws-amplify --save
```
This command will install AWS Amplify and add it to `package.json`

We need to hook up our cognito pool to our code in the `App.js`

```js
import { Amplify } from 'aws-amplify';

Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_APP_AWS_PROJECT_REGION,
   // "aws_cognito_identity_pool_id": process.env.REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_APP_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_AWS_USER_POOLS_WEB_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```
### Insert the following env vars in the `docker.compose.yml` under `frontend-react-js`
```js
REACT_APP_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}"
REACT_APP_AWS_COGNITO_REGION: "${AWS_DEFAULT_REGION}"
REACT_APP_AWS_USER_POOLS_ID: "${AWS_USER_POOLS_ID}"
REACT_APP_CLIENT_ID: "${APP_CLIENT_ID}"
```
To get `APP_CLIENT_ID` click your user pool and  under `App integration`, go to `App client and analytics`

**NB:** Set env vars `AWS_USER_POOLS_ID` and `APP_CLIENT_ID` on the terminal using export and also on gitpod using `gp env "env var" `

## Conditionally show components based on logged in or logged out

In the **homefeedpage.js** insert the following command
```js
import { Auth } from 'aws-amplify';
```

Skip this part because it has been implemented
```js
const [user, setUser] = React.useState(null); To manage user variable or objects
```

delete the code with the  cookies 
```js
  const checkAuth = async () => {
    console.log('checkAuth')
    // [TODO] Authenication
    if (Cookies.get('user.logged_in')) {
        display_name: Cookies.get('user.name'),
        handle: Cookies.get('user.username')
    }
  };
```

and replace with the following that used cognito
```js
// check if we are authenicated
const checkAuth = async () => {
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((user) => {
    console.log('user',user);
    return Auth.currentAuthenticatedUser()
  }).then((cognito_user) => {
      setUser({
        display_name: cognito_user.attributes.name,
        handle: cognito_user.attributes.preferred_username
      })
  })
  .catch((err) => console.log(err));
};

```

Skip this part
```js
// check when the page loads if we are authenicated
React.useEffect(()=>{
  loadData();
  checkAuth();
}, [])
```

Skip this part as well.
```js
<DesktopNavigation user={user} active={'home'} setPopped={setPopped} />
<DesktopSidebar user={user} />
```

We'll update `ProfileInfo.js`

On profileinfo.js, delete the following code
```js
import Cookies from 'js-cookie'
```
and replace with:

```js
import { Auth } from 'aws-amplify';
```

remove the following code
```js
    console.log('signOut')
    // [TODO] Authenication
    Cookies.remove('user.logged_in')
    //Cookies.remove('user.name')
    //Cookies.remove('user.username')
    //Cookies.remove('user.email')
    //Cookies.remove('user.password')
    //Cookies.remove('user.confirmation_code')
    window.location.href = "/"
```

and  replace with the new signout
```js
const signOut = async () => {
    try {
        await Auth.signOut({ global: true });
        window.location.href = "/"
    } catch (error) {
        console.log('error signing out: ', error);
}
```
## Implement the Signin Page
Go to pages and edit `SigninPage.js`
```js
import Cookies from 'js-cookie'

```

and replace with the following
```js
import { Auth } from 'aws-amplify';
```

remove the following code 
```js
  const onsubmit = async (event) => {
    event.preventDefault();
    setErrors('')
    console.log('onsubmit')
    if (Cookies.get('user.email') === email && Cookies.get('user.password') === password){
      Cookies.set('user.logged_in', true)
      window.location.href = "/"
    } else {
      setErrors("Email and password is incorrect or account doesn't exist")
    }
    return false
  }
```
and replace it with the new one
```js
const onsubmit = async (event) => {
    setErrors('')
    event.preventDefault();
    Auth.signIn(email, password)
    .then(user => {
      console.log('user',user)
      localStorage.setItem("access_token", user.signInUserSession.accessToken.jwtToken)
      window.location.href = "/"
    })
    .catch(error => {
      if (error.code == 'UserNotConfirmedException') {
        window.location.href = "/confirm"
      }
      setErrors(error.message)
      });
    return false
  }
```
Run `docker compose up -d` and try to login using any username and password.
 - if you get  "NotAuthorizedException: Incorrect user or password", it's working fine.
 - if you get "SCP_AUTH_NOT_enabled", there is a problem with cognito user pool configuration,Go and recreate. Make sure under app integration, it's on Public Client.

Create a user in the Cognito user pool and use the below command to change the password:
```yml
aws cognito-idp admin-set-user-password \
  --user-pool-id <your-user-pool-id> \
  --username <username> \
  --password <password> \
  --permanent
```

## Implement Signup page
Go to pages and edit `SignupPage.js`

**NB:** We delete our user created from the AWS console because it is no lomger needed.
 remove the following code
```js
import Cookies from 'js-cookie'
```
and replace with the following
```js
import { Auth } from 'aws-amplify';
```

Remove the following code
```js
  const onsubmit = async (event) => {
    event.preventDefault();
    console.log('SignupPage.onsubmit')
    // [TODO] Authenication
    Cookies.set('user.name', name)
    Cookies.set('user.username', username)
    Cookies.set('user.email', email)
    Cookies.set('user.password', password)
    Cookies.set('user.confirmation_code',1234)
    window.location.href = `/confirm?email=${email}`
    return false
  }
```
and add the following code
```js
const onsubmit = async (event) => {
    event.preventDefault();
    setErrors('')
    try {
      const { user } = await Auth.signUp({
        username: email,
        password: password,
        attributes: {
          name: name,
          email: email,
          preferred_username: username,
        },
        autoSignIn: { // optional - enables auto sign in after user is confirmed
          enabled: true,
        }
      }) ;
      console.log(user);
      window.location.href = `/confirm?email=${email}`
    } catch (error) {
        console.log(error);
        setErrors(error.message)
    }
    return false
  }
```
## Implement Confirmation Page
from the `Confirmationpage.js`, remove the following code
```js
import Cookies from 'js-cookie'
```
and replace with the following code
```js
import { Auth } from 'aws-amplify';
```

and remove the following code
```js
  const resend_code = async (event) => {
    console.log('resend_code')
    // [TODO] Authenication
  }
```
and replace with the following code
```js
const resend_code = async (event) => {
 
    setErrors('')
    try {
      await Auth.resendSignUp(email);
      console.log('code resent successfully');
      setCodeSent(true)
    } catch (err) {
      // does not return a code
      // does cognito always return english
      // for this to be an okay match?
      console.log(err)
      if (err.message == 'Username cannot be empty'){
        setCognitoErrors("You need to provide an email in order to send Resend Activiation Code")   
      } else if (err.message == "Username/client id combination not found."){
        setCognitoErrors("Email is invalid or cannot be found.")   
      }
    }
  }

```
and remove the following code
```js
 const onsubmit = async (event) => {
    event.preventDefault();
    console.log('ConfirmationPage.onsubmit')
    // [TODO] Authenication
    if (Cookies.get('user.email') === undefined || Cookies.get('user.email') === '' || Cookies.get('user.email') === null){
      setErrors("You need to provide an email in order to send Resend Activiation Code")   
    } else {
      if (Cookies.get('user.email') === email){
        if (Cookies.get('user.confirmation_code') === code){
          Cookies.set('user.logged_in',true)
          window.location.href = "/"
        } else {
          setErrors("Code is not valid")
        }
      } else {
        setErrors("Email is invalid or cannot be found.")   
      }
    }
    return false
  }
```

and replace with the cognito code
```js
const onsubmit = async (event) => {
  event.preventDefault();
  setErrors('')
  try {
    await Auth.confirmSignUp(email, code);
    window.location.href = "/"
  } catch (error) {
    setErrors(error.message)
  }
  return false
}
```
## Implement Recovery Page
In the `Recoverypage.js`, add the following code:
```js
import { Auth } from 'aws-amplify';
```
remove the following code
```js
  const onsubmit_send_code = async (event) => {
    event.preventDefault();
    console.log('onsubmit_send_code')
    return false
  }
```
and replace with the following code
```js
const onsubmit_send_code = async (event) => {
    event.preventDefault();
    setErrors('')
    Auth.forgotPassword(username)
    .then((data) => setFormState('confirm_code') )
    .catch((err) => setErrors(err.message) );
    return false
  }
```
remove the following code
```js
  const onsubmit_confirm_code = async (event) => {
    event.preventDefault();
    console.log('onsubmit_confirm_code')
    return false
  }
```
and replace with the following code
```js
const onsubmit_confirm_code = async (event) => {
  event.preventDefault();
  setErrors('')
  if (password == passwordAgain){
    Auth.forgotPasswordSubmit(username, code, password)
    .then((data) => setFormState('success'))
    .catch((err) => setErrors(err.message) );
  } else {
    setErrors('Passwords do not match')
  }
  return false
}
```
## Backend Implementation for Cognito
### Authenticating Server Side
We need to protect our Api endpoints. We need to pass along our access token that we stored in our local storage in `SigninPage.js`. This needs to be passed along our api calls.
Add in the `HomeFeedPage.js` a header to pass along the access token after line 26.
```js
  headers: {
    Authorization: `Bearer ${localStorage.getItem("access_token")}`
  }
In `app.py` , add the block of code
```js
cors = CORS(
  app, 
  resources={r"/api/*": {"origins": origins}},
  headers=['Content-Type', 'Authorization'], 
  expose_headers='Authorization',
  methods="OPTIONS,GET,HEAD,POST"
)
```
## Homework Challenges
### Decouple the JWT verify from the application code by writing a  Flask Middleware
To decouple the JWT verification from the application code in Flask, I created a middleware that will handle the verification process before the request reaches the application code.
```py
import jwt
from flask import request, jsonify

class JWTMiddleware:
    def __init__(self, app, secret_key):
        self.app = app
        self.secret_key = secret_key

        @app.before_request
        def verify_jwt():
            auth_header = request.headers.get('Authorization')
            if auth_header:
                token = auth_header.split(' ')[1]
                try:
                    payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
                    # add payload to request context for use in application code
                    request.jwt_payload = payload
                except jwt.InvalidTokenError:
                    return jsonify({'message': 'Invalid token'}), 401

```
In the above code, we define a JWTMiddleware class that takes in the Flask app instance and a secret_key for JWT decoding. We define a before_request function that will be called before any request reaches the application code.

In the before_request function, we first get the Authorization header from the request. If the header exists, we extract the JWT token from it and attempt to decode it using the jwt.decode method. If decoding is successful, we add the decoded payload to the request context using the request.jwt_payload attribute.

If decoding fails, we return a 401 Unauthorized response with an error message. With this middleware, the application code can now access the decoded JWT payload by accessing the request.jwt_payload attribute.

## Decouple the JWT verify by implementing a Container Sidecar pattern using AWS’s official Aws-jwt-verify.js library
To decouple JWT verification from the application code using the Container Sidecar pattern and AWS's official Aws-jwt-verify.js library, we can create a separate container running the sidecar code that will handle the JWT verification. Here's an example of how to implement this pattern:

1. Create a Docker container for the sidecar code that will handle JWT verification. This container should run the AWS official aws-jwt-verify.js library and expose an HTTP endpoint that the main application container can use to verify JWTs.

2. In the main application container, add a middleware that will make an HTTP request to the sidecar container to verify JWTs. Here's an example of how to write a middleware in Flask:
```py
import requests
from flask import request, jsonify

class JWTMiddleware:
    def __init__(self, app, sidecar_url):
        self.app = app
        self.sidecar_url = sidecar_url

        @app.before_request
        def verify_jwt():
            auth_header = request.headers.get('Authorization')
            if auth_header:
                token = auth_header.split(' ')[1]
                response = requests.get(f"{self.sidecar_url}/verify", headers={"Authorization": f"Bearer {token}"})
                if response.status_code == 200:
                    # add payload to request context for use in application code
                    request.jwt_payload = response.json()
                else:
                    return jsonify({'message': 'Invalid token'}), 401
```
In the above code, we define a JWTMiddleware class that takes in the Flask app instance and the URL of the sidecar container. We define a before_request function that will be called before any request reaches the application code.

In the before_request function, we first get the Authorization header from the request. If the header exists, we extract the JWT token from it and make an HTTP request to the sidecar container to verify the token. If the response status code is 200 OK, we add the decoded payload to the request context using the request.jwt_payload attribute. If the response status code is anything else, we return a 401 Unauthorized response with an error message.

With this middleware, the application code can now access the decoded JWT payload by accessing the request.jwt_payload attribute. The JWT verification is decoupled from the application code and handled by the sidecar container.

## Decouple the JWT verify process by using Envoy as a sidecar 
To decouple JWT verification from the application code using Envoy as a sidecar, we can create a separate container running Envoy that will handle the JWT verification. Envoy is a high-performance proxy server that can handle a wide range of tasks including authentication and authorization. Here's an example of how to implement this pattern:

Create a Docker container for the Envoy sidecar that will handle JWT verification. This container should have an Envoy configuration that specifies how to handle JWT verification. Here's an example of an Envoy configuration that handles JWT verification:
```yml
static_resources:
  listeners:
    - name: listener_0
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 8080
      filter_chains:
        - filters:
            - name: envoy.http_connection_manager
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                stat_prefix: ingress_http
                route_config:
                  name: local_route
                  virtual_hosts:
                    - name: jwt_verification
                      domains: ["*"]
                      routes:
                        - match:
                            prefix: "/verify"
                          route:
                            cluster: jwt_verification_cluster
                http_filters:
                  - name: envoy.filters.http.jwt_authn
                    typed_config:
                      "@type": type.googleapis.com/envoy.extensions.filters.http.jwt_authn.v3.JwtAuthentication
                      providers:
                        provider1:
                          issuer: "https://your-issuer-url"
                          audiences: ["your-audience"]
                          remote_jwks:
                            http_uri:
                              uri: "https://your-jwks-url"
                              cluster: jwks_cluster
                              timeout: 5s
                            cache_duration:
                              seconds: 300
                      rules:
                        - match:
                            prefix: "/verify"
                          requires:
                            provider_name: provider1
                            requires_claims:
                              sub: {}
          transport_socket:
            name: envoy.transport_sockets.tls
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
              common_tls_context:
                validation_context:
                  trusted_ca: { filename: /etc/ssl/certs/ca-certificates.crt }

  clusters:
    - name: jwt_verification_cluster
      connect_timeout: 1s
      type: strict_dns
      dns_lookup_family: V4_ONLY
      lb_policy: round_robin
      load_assignment:
        cluster_name: jwt_verification_cluster
        endpoints:
          - lb_endpoints:
              - endpoint:
                  address:
                    socket_address:
                      address: 127.0.0.1
                      port_value: 8081
    - name: jwks_cluster
      connect_timeout: 1s
      type: strict_dns
      dns_lookup_family: V4_ONLY
      lb_policy: round_robin
      load_assignment:
        cluster_name: jwks_cluster
        endpoints:
          - lb_endpoints:
              - endpoint:
                  address:
                    socket_address:
                      address: your-jwks-hostname
                      port_value: your-jwks-port
```
In the above configuration, we define a listener on port 8080 that handles incoming HTTP requests. We define a virtual host for JWT verification that matches incoming requests with the prefix /verify. We define an HTTP filter that handles JWT authentication using the envoy.filters.http.jwt_authn filter. We configure the filter to use a remote JWKS (JSON Web Key Set) URI to validate the JWT signature, and to check that the JWT was issued by a specific issuer and intended for a specific audience. We define two clusters.

## Implement a IdP login eg. Login with Amazon or Facebook or Apple.
To implement an Identity Provider (IdP) login using Login with Amazon, Facebook, or Apple, we can use their respective SDKs to handle the authentication flow. Here's an overview of how to implement this for each IdP:

1. Login with Amazon:

Install the Amazon SDK for Python using pip: pip install amazon-cognito-identity-python
In your Flask app, create a route for handling the Login with Amazon flow. This route should redirect the user to the Amazon login page where they can enter their credentials. After the user logs in, they will be redirected back to a callback URL in your Flask app. In this callback URL route, use the Amazon SDK to exchange the authorization code for an access token and ID token. You can then use the ID token to authenticate the user in your Flask app.
Here's an example of how to create the callback URL route:
```py
import boto3
from amazon_cognito_identity import AWSCognitoIdentityProvider

# configure the Amazon SDK with your app's client ID and pool ID
client_id = 'your-client-id'
user_pool_id = 'your-user-pool-id'
user_pool_region = 'your-user-pool-region'
aws_region = 'your-aws-region'
aws_cognito_idp = boto3.client('cognito-idp', region_name=aws_region)
cognito = AWSCognitoIdentityProvider(
    user_pool_id=user_pool_id,
    client_id=client_id,
    client=aws_cognito_idp
)

# create a route for handling the callback URL after the user logs in
@app.route('/callback')
def callback():
    code = request.args.get('code')
    if not code:
        abort(400, 'Authorization code missing')

    # exchange the authorization code for an access token and ID token
    token_response = cognito.get_id_token(code, redirect_uri='your-callback-url')
    id_token = token_response['AuthenticationResult']['IdToken']

    # verify the ID token and authenticate the user in your app
    # ... (see the JWT verification methods described earlier)
```
    # ... (see the JWT verification methods described earlier)
2. Login with Facebook:

Install the Facebook SDK for Python using pip: pip install facebook-sdk
In your Flask app, create a route for handling the Login with Facebook flow. This route should redirect the user to the Facebook login page where they can enter their credentials. After the user logs in, they will be redirected back to a callback URL in your Flask app. In this callback URL route, use the Facebook SDK to exchange the authorization code for an access token and authenticate the user in your Flask app.
Here's an example of how to create the callback URL route:
```py
import facebook

# create a route for handling the callback URL after the user logs in
@app.route('/callback')
def callback():
    code = request.args.get('code')
    if not code:
        abort(400, 'Authorization code missing')

    # exchange the authorization code for an access token
    access_token_url = 'https://graph.facebook.com/v12.0/oauth/access_token'
    access_token_params = {
        'client_id': 'your-client-id',
        'client_secret': 'your-client-secret',
        'redirect_uri': 'your-callback-url',
        'code': code
    }
    response = requests.get(access_token_url, params=access_token_params)
    access_token = response.json().get('access_token')

    # use the access token to authenticate the user in your app
    graph = facebook.GraphAPI(access_token=access_token, version='3.0')
    profile =
```
## Implement MFA that send an SMS (text message), warning this has spend, investigate spend before considering, text messages are not eligible for AWS Credits
To implement Multi-Factor Authentication (MFA) that sends an SMS text message, we can use the AWS SNS service to send the message. Here's an overview of how to implement this:

Set up an SNS topic:

Log in to your AWS account and navigate to the SNS service.
Create a new topic and configure the settings as needed.
Take note of the topic ARN, which we will use in the Flask app.
Install the AWS SDK for Python using pip: pip install boto3.

In your Flask app, create a route for handling the MFA flow. This route should prompt the user for their phone number and send an SMS message with a one-time code. After the user enters the code, you can authenticate them in your Flask app.
```py
import boto3
from flask import session

# create an SNS client using the AWS SDK
client = boto3.client('sns', region_name='your-aws-region')

# create a route for handling MFA
@app.route('/mfa', methods=['GET', 'POST'])
def mfa():
    if request.method == 'GET':
        # prompt the user for their phone number
        return render_template('mfa.html')

    # send an SMS message with a one-time code
    phone_number = request.form.get('phone_number')
    code = generate_one_time_code()  # implement this function to generate a code
    message = f'Your MFA code is: {code}'
    response = client.publish(
        PhoneNumber=phone_number,
        Message=message
    )

    # store the code and phone number in the session
    session['mfa_code'] = code
    session['phone_number'] = phone_number

    # redirect the user to a page to enter the code
    return redirect('/mfa/verify')

# create a route for verifying the code
@app.route('/mfa/verify', methods=['GET', 'POST'])
def mfa_verify():
    if request.method == 'GET':
        # prompt the user for the code
        return render_template('mfa_verify.html')

    # verify the code and authenticate the user
    code = request.form.get('code')
    if code == session.get('mfa_code'):
        # authenticate the user
        phone_number = session.get('phone_number')
        user = authenticate_with_mfa(phone_number)  # implement this function to authenticate the user with the phone number
        login_user(user)

        # redirect the user to the home page
        return redirect('/')
    else:
        # show an error message
        return render_template('mfa_verify.html', error='Invalid code')
```
**NB:** Sending messages may incure charges.
