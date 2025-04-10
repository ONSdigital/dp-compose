# Auth Stack

This stack deploys the necessary services and dependencies to work with the auth stack.

The auth stack uses the sandbox cognito instance to store users and their permissions.

This stack is for testing and working directly with auth and is not designed to run all services. If you wish to add auth to your stack you can either add `dp-authorisation-stub` or to work directly with auth you can add:

- florence
- dp-identity-api
- dp-permissions-api
- mongodb (required by dp-permissions-api)
- dp-api-router (if you don't have it already)

You would then follow the steps below to add the appropriate environment variables to contact sandbox cognito.

## Getting secrets

To run this stack you will need to obtain the relevant secrets for the `local.env` file, which **must not be committed**:

```sh
# get from:
# AWS > Cognito > User Pools > sandbox-florence-users > user pool ID
AWS_COGNITO_USER_POOL_ID
# get from:
# AWS > Cognito > User Pools > sandbox-florence-users > App Integration > App clients > dp-identity-api > client id
AWS_COGNITO_CLIENT_ID
# get from:
# AWS > Cognito > User Pools > sandbox-florence-users > App Integration > App clients > dp-identity-api > client secret
AWS_COGNITO_CLIENT_SECRET

# Below values from the aws login-dashboard or via `aws sts get-session-token`
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN

# You may also need these AWS settings. The profile should point to dp-sandbox.
AWS_PROFILE
AWS_REGION

# You may also need the following other environment variables. Get the values from the relevant secrets in sandbox:

# TRANSACTION_STORE from the-train
TRANSACTION_STORE

# ENABLE_PRIVATE_ENDPOINTS from dp-api-router
ENABLE_PRIVATE_ENDPOINTS

# ENABLE_PERMISSIONS_AUTH from zebedee
ENABLE_PERMISSIONS_AUTH

# IS_PUBLISHING from the permissions api and/or the files api and/or the image api
IS_PUBLISHING
```

To get the aws values from the dashboard do the following:

- Login to the AWS [console](https://ons.awsapps.com/start#/).
- Expand ons-dp-sandbox and click on `Access keys`.
- Expand `Option 1: Set AWS environment variables` and click the copy button.
- Copy the values into your local.env file. Delete the word 'export' from each line. But keep the quotes around the values. NB. These are the only values in your local.env that may need to have quotes around them.

Note that the AWS_SESSION_TOKEN is only valid for 12 hours. Once the token has expired you would need to stop the stack, retrieve and set new credentials before running the stack again.

## Testing

To know this stack has worked you can do the following things:

- [login to florence](http://localhost:8081/florence/login) with your sandbox login
- log out of florence
- "forget" your password
- view all users [via the api](http://localhost:8081/florence/api/v1/users)
- view all groups [via the api](http://localhost:8081/florence/api/v1/groups)
- CRUD users in florence (if you're an admin)
- CRUD groups in florence (if you're an admin)

This list is not definitive and should be taken as a guide only.
