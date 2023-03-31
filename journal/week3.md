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
