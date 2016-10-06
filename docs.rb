require_relative "routes"
require_relative "helpers"
require "rubygems"
require "sinatra"
require "sinatra/content_for"
require "sinatra/partial"
require "stringex"
require "i18n"
require "i18n/backend/fallbacks"
require "rack-ssl-enforcer"
require "rack/protection"
require 'rack/csrf'
require 'secure_headers'
require 'tilt/erb'
require "json"
require "pony"

class Docs < Sinatra::Base
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'cloudwalk.io',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }

  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'config/locales', '*.yml')]
    I18n.backend.load_translations
    I18n.enforce_available_locales = false

    use Rack::SslEnforcer if production?
    use Rack::Csrf if production?
    use Rack::Protection

    enable :sessions

    use Rack::Session::Cookie, :key => ENV['SESSION_KEY'],
                               :domain => 'cloudwalk.io',
                               :path => '/',
                               :expire_after => 2592000, # In seconds
                               :secret => ENV['SESSION_SECRET'] if production?

    use SecureHeaders::Middleware

    SecureHeaders::Configuration.default do |c|
      c.hsts = 'max-age=631152000; includeSubdomains; preload'
      c.x_frame_options = 'DENY'
      c.x_content_type_options = 'nosniff'
      c.x_xss_protection = '1; mode=block'
      c.x_download_options = 'noopen'
      c.x_permitted_cross_domain_policies = 'none'
      c.csp = {
        default_src: %w('self'),
        font_src: %w('self' maxcdn.bootstrapcdn.com),
        img_src: %w('self'),
        media_src: %w('self'),
        object_src: %w('self'),
        script_src: %w('self' 'unsafe-inline' gist.github.com),
        style_src: %w('self' 'unsafe-inline' maxcdn.bootstrapcdn.com assets-cdn.github.com),
        base_uri: %w('self'),
        child_src: %w('self' www.youtube.com),
        form_action: %w('self'),
        frame_ancestors: %w('none')
      }
    end

    set :views, File.dirname(__FILE__) + '/templates'

    register Sinatra::Partial
    set :partial_template_engine, :erb
  end

  before '/:locale/*' do
    I18n.locale = params[:locale] if ["en", "pt-BR"].include?(params[:locale])
  end

  not_found do
    erb :not_found
  end

  # Locale
  post '/' do
    old_locale = params["url"].split("/")[1]
    redirect params["url"].sub(old_locale, params["locale"]), 301
  end

  # Landing page
  get "/" do redirect "/#{I18n.locale}/introduction" end

  # Navigation pages
  Routes.navigation.each do |item|
    get "/#{item["url"]}" do redirect "/#{I18n.locale}/#{item["url"]}", 301 end
    get "/:locale/#{item["url"]}" do |locale|
      @params = request.env['rack.request.query_hash']
      erb "#{item["view_path"]}".to_sym
    end
  end

  # Discontinued
  paths = ['framework/verifone-verix', 'framework/ingenico-telium-1']

  paths.each do |path|
    get "/#{path}" do redirect '/', 301 end
    get "/:locale/#{path}" do redirect '/', 301 end
  end

  # POSXML commands
  Routes.commands.each do |command|
    get "/posxml/commands/#{command}" do redirect "/#{I18n.locale}/posxml/commands/#{command}", 301 end
    get "/:locale/posxml/commands/#{command}" do |locale|
      erb "posxml/commands/#{command}".to_sym
    end
  end

  get "/:locale/search" do |locale|
    if params[:query]
      @results = search
    else
      redirect "/#{I18n.locale}/introduction", 301
    end

    erb :search
  end

  helpers do
    include Helpers
    helpers Sinatra::ContentFor
  end
end
