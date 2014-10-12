# CloudWalk Docs

[![Dependency Status](https://gemnasium.com/cloudwalkio/cloudwalk-docs.png)](https://gemnasium.com/cloudwalkio/cloudwalk-docs)

[CloudWalk's](https://cloudwalk.io) open-source documentation project built on top of Sinatra.

## Contributions

Pull requests are welcomed.

## Getting Started

Be sure Bundler is installed. After cloning the repo:

```console
$ bundle install
$ bundle exec rackup
```

## Testing

The following environment variables are required:

- **ADMIN_CONTACT_EMAIL:** In case of errors
- **SEARCH_API_TOKEN:** Search API endpoint
- **SEARCH_API_URL:** Search API token

Assuming that everything is set, the test suite can be started:

```console
ruby docs_test.rb
```
## More information

[https://docs.cloudwalk.io](https://docs.cloudwalk.io)

© 2014 CloudWalk
