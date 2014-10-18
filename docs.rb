require_relative "routes"
require "rubygems"
require "sinatra"
require "newrelic_rpm"
require "sinatra/content_for"
require "sinatra/partial"
require "i18n"
require "i18n/backend/fallbacks"
require "rack-ssl-enforcer"
require "json"
require "pony"

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

  enable :sessions

  use Rack::Session::Cookie, :key => ENV['SESSION_KEY'],
                             :domain => 'cloudwalk.io',
                             :path => '/',
                             :expire_after => 2592000, # In seconds
                             :secret => ENV['SESSION_SECRET'] if production?

  set :views, File.dirname(__FILE__) + '/templates'
  set :partial_template_engine, :erb
end

before '/:locale/*' do
  I18n.locale = params[:locale]
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
  def link_to(name, url)
    "<a href='/#{I18n.locale}/#{url}'>#{name}</a>"
  end

  def is_group_active?(group)
    "in" if group == request.path_info.split("/")[2]
  end

  def is_group_item_active?(group=nil, item=nil)
    if group == request.path_info.split("/")[2]
      return "active" if request.path_info.split("/").length == 3 && item.nil?
      return "active" if item == request.path_info.split("/").last
    end
  end

  def option_select(value, text, current=nil)
    selected = validate_option_value(value, current)
    "<option value=#{value}#{selected}>#{text}</option>"
  end

  def validate_option_value(value, current)
    ' selected' if value == current.to_s
  end

  def check_param(params, name, valid_options=nil)
    return "none" if params.empty?
    valid_options.member?(params[name]) ? params[name] : nil
  end

  def search
    require 'net/http'

    uri = URI.parse(URI.encode(build_search_url))
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    raise res.body unless res.code == "200"

    JSON.parse(res.body)
  rescue
    send_mail("Search error", "Could not perform search.\n\n#{$!.class}: #{$!.message}\n\nQuery: #{params[:query]}")
    return false
  end

  def build_search_url
    # http://domain.com/en?query=something&access_token=secret

    search_url = ENV["SEARCH_API_URL"].dup
    search_url << I18n.locale.to_s
    search_url << "?query=#{params[:query]}"
    search_url << "&access_token=#{ENV["SEARCH_API_TOKEN"].dup}"
  end

  def parse_search_results(response)
    markup = ""

    if response["results"].count > 0
      # Open a list
      markup = "<ul class='search-listing'>"

      # Iterate on entries
      response['results'].each do |entry|
        # Add a list item
        markup << "<li><a href='#{entry["url"]}'>#{entry["title"]}</a><p class='muted'>#{entry["description"]}</p></li>"
      end

      # Close the list
      markup << "</ul>"
    else
      # Not found
      markup = "<br/><p>#{I18n.t("search.success.no_results")}</p>"
    end
    markup
  end

  def send_mail(subject, body)
    Pony.mail :to => ENV["ADMIN_CONTACT_EMAIL"].dup,
              :from => "docs@cloudwalk.io",
              :subject => subject,
              :body => body
  end
end
