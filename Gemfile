source 'https://rubygems.org'

ruby '2.1.2'

gem 'i18n',            '~> 0.6.11'
gem 'pony',            '~> 1.11'
gem 'sinatra',         '~> 1.4.5'
gem 'sinatra-contrib', '~> 1.4.2'
gem 'sinatra-partial', '~> 0.4.0'
gem 'thin',            '~> 1.6.2'

group :test do
  gem 'rack-test', '~> 0.6.2'
  gem 'simplecov', '~> 0.9.0', :require => false
end

group :production do
  gem 'rack-ssl-enforcer', '~> 0.2.8'
  gem 'newrelic_rpm',      '~> 3.9.4.245'
end
