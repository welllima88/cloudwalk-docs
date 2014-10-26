# CloudWalk Docs

[![Build Status](https://travis-ci.org/cloudwalkio/cloudwalk-docs.svg?branch=master)](https://travis-ci.org/cloudwalkio/cloudwalk-docs)
[![Coverage Status](https://img.shields.io/coveralls/cloudwalkio/cloudwalk-docs.svg)](https://coveralls.io/r/cloudwalkio/cloudwalk-docs?branch=master)
[![Dependency Status](https://gemnasium.com/cloudwalkio/cloudwalk-docs.png)](https://gemnasium.com/cloudwalkio/cloudwalk-docs)

CloudWalk open-source documentation built on top of Sinatra.

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
- **SEARCH_API_TOKEN:** Search API token
- **SEARCH_API_URL:** Search API endpoint

Assuming that everything is set, the test suite can be started:

```console
$ ruby docs_test.rb
```

## More information

[https://docs.cloudwalk.io](https://docs.cloudwalk.io)

© 2014 CloudWalk
