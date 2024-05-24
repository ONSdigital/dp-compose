# Auth Stack

This stack deploys the necessary services and dependencies to work with the auth stack.

The auth stack uses the sandbox cognito instance to store users and their permissions.

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

# This should be your locally generated token by Zebedee
SERVICE_AUTH_TOKEN

# You'll also need your zebedee root for content
# E.g. zebedee_root=/Users/your-name/zebedee-content
zebedee_root

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
