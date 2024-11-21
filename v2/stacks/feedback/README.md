# Feedback Stack

This stack deploys the necessary services and dependencies for feedback service including the feedback api, upstream services and local mail server.

The stack uses:

- dp-frontend-feedback-controller
- dp-frontend-search-controller
- dp-frontend-router
- dp-feedback-api
- dp-api-router
- dp-design-system
- mailhog
- http-echo

## Is it running successfully?

This stack should allow you access these routes:

- [feedback](http://localhost:25200/feedback)
- [search](http://localhost:25000/search)

Routes with `dp-frontend-router`

- [feedback](http://localhost:20000/feedback)
- [search](http://localhost:20000/search)

And have a local mail server running:

- [mailhog](http://127.0.0.1:8025/#)

## Feature flag for `dp-feedback-api`

If you want to turn on the feature flag for `dp-feedback-api` so the controllers and footer feedback form post to it;

You should:

- rename the `local.env.tmpl` => `local.env`. This will override these configs for the following services:
  - ENABLE_FEEDBACK_API to `true`
        - `dp-api-router`
        - `dp-frontend-feedback-controller`
        - `dp-frontend-search-controller`

You can change it back to `false` to turn off the feature flag for `dp-feedback-api`.

## What to expect

When running you should be able to:

- Access the feedback and search service with their own routes and `dp-frontend-router` routes
- Access the `feedback` page, fill in the form and if the form is valid, get a thank you message and an email on mailhog
- Access the `search` page and interact with the feedback footer:
  - Click `Yes`, get a thank you message with no email sent
  - Click `No`, fill in the form and if the form is valid, get a thank you message and an email on mailhog
  - NOTE: if `ENABLE_FEEDBACK_API` is set to `false`, submitting feedback from an upstream controller will only work when proxied via the `dp-frontend-router`.
