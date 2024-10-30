# Data API Stack

This stack deploys the necessary services and dependencies to work with the data api stack.

The auth stack uses the sandbox cognito instance to store users and their permissions.

## Getting secrets

To run this stack you will need to obtain the relevant secrets for the `local.env` file, which **must not be committed**:

```sh
# get from AWS > Cognito > User Pools > sandbox-florence-users > user pool ID
AWS_COGNITO_USER_POOL_ID
# get from AWS > Cognito > User Pools > sandbox-florence-users > App Integration > App clients > dp-identity-api > client id
AWS_COGNITO_CLIENT_ID
# get from AWS > Cognito > User Pools > sandbox-florence-users > App Integration > App clients > dp-identity-api > client secret
AWS_COGNITO_CLIENT_SECRET

# Below values from the aws login-dashboard or via `aws sts get-session-token`
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN

# This should be your locally generated token by Zebedee
SERVICE_AUTH_TOKEN

# You'll also need your zebedee root for content
zebedee_root
```

To get the aws values from the dashboard do the following:

- login to the AWS [console](https://ons.awsapps.com/start#/)
- click on `Command line or programmatic access`
- click on `Option 1: Set AWS environment variables (Short-term credentials)`
- copy the highlighted values

Note that the AWS_SESSION_TOKEN is only valid for 12 hours. Once the token has expired you would need to stop the stack, retrieve and set new credentials before running the stack again.

## Gotchas

In the `Makefile` of the stack there is a `DEFAULT_KEYS_FOLDER` variable that is set to point in the `static/keys` folder in the `dis-authentication-stub` repo.
Running the `make up` command will run also the `init` target in the `Makefile` trying to decrypt the files that are inside that folder.
If you run the `make up` command and you get an error saying that there are not such files in the folder please change the value `DEFAULT_KEYS_FOLDER` variable to the 
fully qualified path of the `static/keys` folder.