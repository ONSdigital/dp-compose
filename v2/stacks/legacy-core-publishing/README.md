# Legacy Core Publishing Stack

This stack deploys the necessary services and dependencies to work with the legacy core stack in publishing mode.

The stack uses the sandbox instance of dp-identity-api to simplify the approach to using auth.

## Initialisation

To connect to the dp-identity-api in sandbox you will need to port forward the address.

```sh
    dp ssh sandbox publishing_mount 1 -p 25600:localhost:$IDENTITY_API_PORT
```

`$IDENTITY_API_PORT` can be found in the [list of nomad ports](https://github.com/ONSdigital/dp-setup/blob/awsb/PORTS.md)

## Testing

To know this stack is working as expected, run `make up` and then check if you can login to Florence via `localhost:8081/florence/login`.

Further functionality to test will be added as this stack is expanded and proved.
