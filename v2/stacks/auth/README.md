# Auth Stack

This stack deploys the necessary services and dependencies to work with the auth stack.

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

# Example on how to debug a Go application running in docker 

This example will show how we can debug `dp-identity-api` when we run the auth stack.

- Copy and paste the following code into the `Dockerfile.local` file in `dp-identity-api` repo

```sh
FROM golang:1.21-bullseye AS base

ENV GOCACHE=/go/.go/cache GOPATH=/go/.go/path TZ=Europe/London

RUN GOBIN=/bin go install github.com/cespare/reflex@v0.3.1
RUN GOBIN=/bin go install github.com/go-delve/delve/cmd/dlv@latest
RUN PATH=$PATH:/bin

ENV PATH=$PATH
# Clean cache, as we want all modules in the container to be under /go/.go/path
RUN go clean -modcache

COPY . .
RUN go build -gcflags="all=-N -l" -o /go/server
ENTRYPOINT ["dlv", "--log", "--listen=:2345", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "./server"]
```

- Change the `BuildTime`, `GitCommit`, `Version` variables in the `dp-identity-api/main.go` file and assign them a string literal value (for example `"1"`).
- Remove the `command` section of the `dp-compose/v2/manifests/core-ons/dp-identity-api.yml` file.
- Expose the port on which the debugging server is running on by adding `- "2345:2345"` (in this example is 2345) to the ports sections of the `dp-compose/v2/manifests/core-ons/dp-identity-api.yml` file.
- In IntelliJ IDE or Goland IDE open `dp-identity-api` repo and on the menu bar click `Run->Edit Configurations...`. On the popup window on the left corner click the `+` button and choose `Go Remote` (the default port should be 2345). Put also a useful name next to the `Name:` label. Hit `Apply` and `Ok`. 
- Run the auth stack if it is not running already (make sure to remove dp-identity-api image first) or if you are already running it, run `make refresh SERVICE=dp-identity-api`.
- Put your breakpoints in the code that you want to debug.
- On the menu bar click `Run->Debug Name-that-you-chose`.