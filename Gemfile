source 'https://rubygems.org'

ruby '2.2.0'

gem 'i18n'
gem 'pony'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-partial'
gem 'thin'

group :test do
  gem 'mocha'
  gem 'rack-test'
  gem 'simplecov'
  gem 'coveralls', require: false
end

group :production do
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'rack-ssl-enforcer'
end
