# dp-compose

A project to assist in composing multiple DP services

## Getting started

### V2

There is a version 2 folder (`v2`), which contains different docker compose definitions for each stack.

Please, have a look at the [version 2 README](./v2/README.md) for more information, especially if you are new to dp-compose.

#### Upgrading to V2

If you were using the original stack provided in the root of this repo, this stack has been retired so you will need to upgrade to v2.

In order to smooth the transition to v2, a [`v1-compat`](v2/stacks/v1-compat/) stack has been created that provides the same services as the original v1 stack. Differences exist in the make targets so please see the [`v1-compat` readme](v2/stacks/v1-compat/README.md#migrating-from-the-v1-stack) for more details.

### Non-v2 stacks

There are some stacks in this directory (not the `v2/` directory) which are similar to V2 stacks. These stacks formed the basis for the approach taken with V2, but have yet to be migrated to be inline with V2 themselves:

* [cantabular-import](./cantabular-import/)
* [cantabular-metadata-pub](./cantabular-metadata-pub/)

These stacks will be migrated under v2 in time and no further stacks should be added outside of v2.

These stacks also assume you already have Colima running. See the section on [Colima](#colima) for more information.

## Colima

Running dp-compose assumes Docker is running natively and not in a VM. On a Mac this requires Colima:

[Setting up Colima locally](setting-up-colima-locally.md)

## Kafka

More information about working with the kafka cluster provided by stacks in this repo can be found [here](./kafka-cluster.md).

## Redis

When running Redis in the legacy-core-publishing or legacy-core-web stacks, you can use the add-redirects script to add 20 redirect keys and values to your local Redis store.
This can be done as follows:

```shell
cd v2/scripts
go run .
```

For a local Redis UI, to see the keys amd values that have been set, it is recommended to use Redis Insight, which can be downloaded from here: https://redis.io/downloads/

## Versioning

Dependencies should be kept at specific versions and up-to-date with production.
Previously we were just using 'latest' and out-of-date versions which both could lead to unexpected behaviour.
This repository should be the source of truth for which versions to use for dependencies.
