# Fixing Colima-Related Errors

This guide explains possible fixes for errors that may occur when running Colima.

## Error Getting Credentials

When running docker commands using colima, for the first time, you may receive the following error:

```shell
error getting credentials - err: exec: "docker-credential-desktop": executable file not found in $PATH, out: 
```

To fix this you can try amending the following file:

~/.docker/config.json

It needs to look something like this:

```json
{
  "auths": {
    "https://index.docker.io/v1/": {}
  },
  "currentContext": "colima"
}
```

## Dubious Ownership Error

This error actually comes from Git, which is used by Colima. Git now examines parent directories to determine whether the same user owns both directories. If not, it requires the directory to be whitelisted to enable trust. The way to whitelist it is by adding the following kind of thing to ~/.gitconfig

```git
[safe]
    directory = <directory path>
```

For example:

```git
[safe]
    directory = /go
    directory = /another/safe/directory
```

However, this can also be done programmatically by using the following command:

`git config --global --add safe.directory <directory path>`

E.g.

`git config --global --add safe.directory /go`

Importantly, though, the error usually occurs when Colima is used to run stacks of docker containers, and can be found in individual container logs. E.g.

```shell
make: *** [Makefile:22: debug] Error 1
fatal: detected dubious ownership in repository at '/service'
To add an exception for this directory, call:
```

So, to fix this error inside a docker container, it is necessary to amend the Dockerfile.local, for the relevant service, by adding the following line before it calls the offending directory:

`RUN git config --global --add safe.directory <directory path>`

E.g.

`RUN git config --global --add safe.directory /go`

Then delete any previously built container and retry.

NB. The solution to this error is also explained here: https://stackoverflow.com/questions/72978485/git-submodule-update-failed-with-fatal-detected-dubious-ownership-in-reposit
