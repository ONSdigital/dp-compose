# SecAuth

## Updated instructions to use cognito authenticated user (connect local env with cloud-cognito)

- Make sure you are a cognito recognised user (in group sandbox-florence-users)
- Make sure you are part of a suitable group role-admin / role-publisher.
- Populate the `local.env` with correct aws details [if testing with auth, set `AUTHORISATION_ENABLED=true`].
- Bring up the stack locally (see command below).
- Populate the permissions database (`go run import.go`  [in dp-permissions/import-script])
- The AWS group (role-admin/publisher) maps to certain permissions (see dp-permissions).
- Login and get a bearer token (see curl command below)
    For sandbox, you should be able to port forward dp-identity-api and run the above curl command.
- Add the token to any request (sent to dp-files etc), dp-auth will correctly check permissions.

### For service access (service auth token)

- Every zebedee service auth token has the service name encoded in the token.
- You can test the above by: `curl -i -X GET http://localhost:10050/identity -H "Authorization: Bearer $SERVICE_AUTH_TOKEN"`
- The dp-auth api uses this identity to check for access/permissions.
- Configure this identity in the [dp-permissions api](https://github.com/ONSdigital/dp-permissions-api/blob/develop/import-script/README.md).

## PreReq

- Add another target to dp-intentity-api Makefile:

   ```make
   .PHONY: run
   run:
       HUMAN_LOG=1 go run $(LDFLAGS) -race main.go
   ```

   Note: the awscli stuff shouldnt exist imho - these should be managed like other secrets.

- Make sure you can login via florence - as per new auth
- Populate `local.env` with AWS secrets

## Usage

- Start env - `docker-compose --project-dir . -f profiles/static-files-with-auth.yml up -d`
- Test a login:

    ```sh
    curl -v --location --request POST 'http://localhost:25600/v1/tokens' \
    --header 'Content-Type: application/json' \
    --header 'Accept: text/plain' \
    --data-raw '{
    "email": "[email]",
    "password": "[password]"
    }'
    ```

## Plan

I cant see my trello ticket: https://trello.com/c/qBf8Q9Rl/1206-spike-investigate-auth-for-static-files

But in general my plan was to use dp-uploads-service upload endpoint to understand and implement the correct permissions for uploading from florence and also uploading service-to-service e.g. from interactives importer.

### Test request

```sh
curl --location --request POST 'http://localhost:25100/upload-new?path=testing/docs&resumableFilename=file019&resumableChunkNumber=1&resumableType=text/plain&resumableTotalChunks=1&resumableChunkSize=100&isPublishable=true&resumableTotalSize=100&licence=na&licenceUrl=na&collectionId=markryantests002-7571b9b971f83ad37e8358b6d9e02e63e69e1edfe43ee6fae624ce1bf8d5e676' \
--form 'file=@"/Users/markryan/qnap/workspace/methods/ons/dp/README.md"'
```

with new auth enabled i see, as expected an auth error: `{"errors":[{"code":"InternalError","description":"you are not authorized for this action"}]}`

## Investigation

1. Understand how perms are setup - locally we need to load the perms: https://github.com/ONSdigital/dp-permissions-api/blob/develop/import-script/README.md - imho this should be a Docker container with these scripts baked in and part of the env setup (possibly using profiles: https://docs.docker.com/compose/profiles/#auto-enabling-profiles-and-dependency-resolution) - we also prob need to attach the static-files perms to our Cognito user (i didnt get this far)
1. Get that request passing - it should work once above done as error locally is:

   ```log
   dp-compose-dp-files-api-1  | {
   dp-compose-dp-files-api-1  |   "created_at": "2022-09-30T10:04:17.561391261Z",
   dp-compose-dp-files-api-1  |   "data": {
   dp-compose-dp-files-api-1  |     "permission": "static-files:create"
   dp-compose-dp-files-api-1  |   },
   dp-compose-dp-files-api-1  |   "event": "permission not found in permissions bundle",
   dp-compose-dp-files-api-1  |   "namespace": "dp-files-api",
   dp-compose-dp-files-api-1  |   "severity": 2,
   dp-compose-dp-files-api-1  |   "trace_id": "bzYAKvFCTRLZPzMh,dEZzRWdd"
   dp-compose-dp-files-api-1  | }
   ```

1. investigate work to enable on dp-upload-service - its totally missing from all endpoints: https://github.com/ONSdigital/dp-upload-service/blob/0d9343e967ef7e92444b1331593ecc05edcc0fe0/service/service.go#L84
