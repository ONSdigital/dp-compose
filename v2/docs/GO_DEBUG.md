# Example on how to debug a Go application running in docker

This example will show how we can debug `dp-identity-api` with IntelliJ Universal or Goland IDE when we run the auth stack in docker.

- Replace the contents of the `Dockerfile.local` file (in the `dp-identity-api`) with the following code

```docker
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
- Expose the port on which the debugging server is running on by adding `- "2345:2345"` (in this example is 2345) to the ports section of the `dp-compose/v2/manifests/core-ons/dp-identity-api.yml` file.
- In IntelliJ IDE or Goland IDE open `dp-identity-api` repo and on the menu bar click `Run->Edit Configurations...`. On the popup window in the top left corner click the `+` button and choose `Go Remote` (the default port should be 2345). Put also a useful name next to the `Name:` label. Hit `Apply` and `Ok`.
  ![Run/Debug Configurations screenshot](../../v2/assets/screenshot.png?raw=true "Run/Debug Configurations")
- Run the auth stack if it is not running already (make sure to remove dp-identity-api image first) or if you are already running it, run `make refresh SERVICE=dp-identity-api`.
- Put your breakpoints in the code that you want to debug.
- On the menu bar click `Run->Debug Name-that-you-chose`.
