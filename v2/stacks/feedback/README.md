# Feedback Stack

This stack deploys the necessary services and dependencies for feedback service including the feedback api, upstream services and local mail server.

The stack uses:
- dp-frontend-feedback-controller
- dp-frontend-search-controller
- dp-frontend-router
- dp-feedback-api
- dp-api-router
- dp-design-system
- zebedee
- elasticsearch
- mailhog

## Dependencies

This stack relies on having a local zebedee content store setup correctly and the correct path set to $zebedee_root

See the [zebedee getting started guide](https://github.com/ONSdigital/zebedee#getting-started) for more information.

## Is it running successfully?
This stack should allow you access these routes:
- [feedback](http://localhost:25200/feedback)
- [search](http://localhost:25000/search)

And have a local mail server running:
- [mailhog](http://127.0.0.1:8025/#)

## What to expect
When running you should be able to:
- Access the `feedback` page, fill in the form and if form is valid, get a thank you message and an email on mailhog
- Access the `search` page
    - Click `Yes`, get a thank you message with no email sent
    - Click `No`, fill in the form and if form is valid, get a thank you message and an email on mailhog