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
