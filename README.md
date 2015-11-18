# Docs [![Build Status](https://travis-ci.org/cloudwalkio/cloudwalk-docs.svg?branch=master)](https://travis-ci.org/cloudwalkio/cloudwalk-docs) [![Coverage Status](https://img.shields.io/coveralls/cloudwalkio/cloudwalk-docs.svg)](https://coveralls.io/r/cloudwalkio/cloudwalk-docs?branch=master) [![Dependency Status](https://gemnasium.com/cloudwalkio/cloudwalk-docs.png)](https://gemnasium.com/cloudwalkio/cloudwalk-docs)

![Docs](https://dl.dropboxusercontent.com/u/440273/docs.png)

CloudWalk open-source documentation.

## Table of contents

* [Getting Started](#getting-started)
* [Testing](#testing)
* [Contributing](#contributing)
* [More information](#more-information)

## 1. Getting Started

Be sure Bundler is installed. After cloning the repo:

```console
$ bundle install
$ bundle exec rackup
```
## 2. Testing

The following environment variables are required:

- **ADMIN_CONTACT_EMAIL:** In case of errors
- **SEARCH_API_TOKEN:** The search API token
- **SEARCH_API_URL:** The search API endpoint

Assuming that everything is set, the test suite can be started:

```console
$ ruby docs_test.rb
```

## 3. Contributing

Looking to contribute something to the docs? Great! Please take a moment to review this section in order to make the contribution process easy and effective for everyone involved.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this project. In return, they should reciprocate that respect in addressing your issue or assessing patches and features.

### 3.1 Texts

The CloudWalk Docs provides Portuguese (pt-BR) and English (en) content, so texts should always be translated to both languages. The gem i18n makes the internationalization process pretty straightforward.

### 3.2 Images

Screen-shots should be standard. Since developers use different browsers, the [browser-navigation-bar](https://docs.cloudwalk.io/img/browser-navigation-bar.jpg) image should be used to fake the browser.

Additional information:

  - Type: JPEG image
  - Quality: High (at least 60%)
  - Dimensions: 1600 x 966 (total, including the browser navigation bar)
  - Corners: Right angle, 90 degrees (no rounded cornes)
  - Alternate text (`alt`): A short and descriptive text (I18n'ed, when necessary)
  - CSS: The class `img-polaroid` should be used

Example: [https://docs.cloudwalk.io/en/ide/overview](https://docs.cloudwalk.io/en/ide/overview)

#### Image internationalization

Just like texts, images with text should also be internationalizationed (two different images).

Example:

```erb
<img src="/img/<%= I18n.locale %>/manager/api-token.png" class="img-polaroid" alt="Developer API" />
```

The above definition can result on two different paths: Portuguese (`/img/pt-BR/...`) or English (`/img/en/...`).

## 4. More information

[https://docs.cloudwalk.io](https://docs.cloudwalk.io)

© 2013-2015 CloudWalk
