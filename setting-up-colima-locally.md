# Setting up Colima Locally

Colima means Containers on Linux Machines. It's a Docker Desktop alternative for macOS and Linux.

## How to Install Colima

Simply install colima using brew.

```shell
brew install colima
```

You will also need to make sure that you've installed docker and docker-compose.

```shell
brew install docker
brew install docker-compose
```

## How to Use Colima

Colima can be started and stopped very simply, as follows:

```shell
colima start
colima stop
```

When colima is running then it will automatically start the docker daemon and allow you to use all the usual docker and docker-compose commands as normal e.g

```shell
docker container ls -a
docker ps
docker logs <container>
docker-compose up -d
```

However, if using colima to run any of the v2 stacks, in dp-compose, it is better to give colima more cpu and memory than the default amount. To do that requires starting colima like this:

```shell
colima start --cpu 4 --memory 8 --disk 100
```

Colima can also be used to delete all existing images, containers, and volumes, with the following command:

```shell
colima delete
```

It will give you the following prompts though:

```shell
are you sure you want to delete colima and all settings? [y/N] y
this will delete ALL container data. Are you sure you want to continue? [y/N] y
INFO[0008] deleting colima
INFO[0009] done
```

## How to Fix Colima-Related Errors

To fix common errors that occur, especially when running the V2 stacks using colima, please see this guide:

[Fixing Colima errors](fixing-colima-related-errors.md)
