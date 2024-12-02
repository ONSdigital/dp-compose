# v1 Compatability Stack

:warning: This stack is only provided for backwards compatability with the original docker compose stack. It is strongly recommended that you use the product specific stacks. This stack should be treated as deprecated and not be extended.

This stack only provides the third party backing services and the MathJax API. It provides backwards compatability as a replacement for the original `docker-compose.yml` from the root of this repo.

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by running the health checks:

```shell
make health
```

## Is it complete?

Yes, this stack provides all services provided by the original docker compose stack so can be used as a replacement.
