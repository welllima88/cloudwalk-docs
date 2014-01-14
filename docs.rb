require "rubygems"
require "sinatra"
require "sinatra/content_for"
require 'sinatra/partial'
require "i18n"
require "i18n/backend/fallbacks"
require "rack-ssl-enforcer"
require "json"
require "pony"

configure do
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  Dir.glob('locales/*.yml').each { |locale| I18n.load_path << locale}
  I18n.backend.load_translations
  I18n.enforce_available_locales = false
end

if production?
  use Rack::SslEnforcer
  use Rack::Session::Cookie, :key => ENV["SESSION_KEY"],
                             :secret => ENV["SESSION_SECRET"],
                             :domain => 'cloudwalk.io',
                             :path => '/',
                             :expire_after => 2592000 # In seconds
end

set :partial_template_engine, :erb
set :views, File.dirname(__FILE__) + '/templates'

before do
  set_locale
end

not_found do
  erb :not_found
end

# HOME
get "/" do redirect "/#{current_locale}/introduction" end

@navigation = [
  # OVERVIEW
  { "url" => "introduction",                         "view_path" => "introduction/index"},
  { "url" => "introduction/walk-framework",          "view_path" => "introduction/walk_framework"},
  { "url" => "introduction/walk-manager",            "view_path" => "introduction/walk_manager"},
  { "url" => "introduction/development-environment", "view_path" => "introduction/development_environment"},
  { "url" => "introduction/posxml",                  "view_path" => "introduction/posxml"},
  # WALK FRAMEWORK
  { "url" => "walk-framework/verifone-evo",          "view_path" => "walk_framework/verifone_evo"},
  { "url" => "walk-framework/verifone-evo-vx805",    "view_path" => "walk_framework/verifone_evo_vx805"},
  { "url" => "walk-framework/verifone-verix",        "view_path" => "walk_framework/verifone_verix"},
  { "url" => "walk-framework/ingenico-telium-1",     "view_path" => "walk_framework/ingenico_telium_1"},
  { "url" => "walk-framework/ingenico-telium-2",     "view_path" => "walk_framework/ingenico_telium_2"},
  { "url" => "walk-framework/first-launch",          "view_path" => "walk_framework/first-launch"},
  { "url" => "walk-framework/configuration",         "view_path" => "walk_framework/configuration"},
  # WALK MANAGER
  { "url" => "walk-manager/apps",                    "view_path" => "walk_manager/apps"},
  { "url" => "walk-manager/devices",                 "view_path" => "walk_manager/devices"},
  { "url" => "walk-manager/groups",                  "view_path" => "walk_manager/groups"},
  { "url" => "walk-manager/logical-numbers",         "view_path" => "walk_manager/logical_numbers"},
  { "url" => "walk-manager/assets",                  "view_path" => "walk_manager/assets"},
  { "url" => "walk-manager/transactions-monitor",    "view_path" => "walk_manager/transactions_monitor"},
  # DEVELOPMENT ENVIRONMENT
  { "url" => "development-environment/overview",     "view_path" => "development_environment/overview"},
  # POSXML
  { "url" => "posxml/structure",                     "view_path" => "posxml/structure"},
  { "url" => "posxml/memory-and-variables",          "view_path" => "posxml/memory_and_variables"},
  { "url" => "posxml/file-system",                   "view_path" => "posxml/file_system"},
  { "url" => "posxml/configuration",                 "view_path" => "posxml/configuration"},
  { "url" => "posxml/commands",                      "view_path" => "posxml/commands"},
  # DEVELOPER API
  { "url" => "api/overview",                         "view_path" => "api/overview"},
  { "url" => "api/v1/apps",                          "view_path" => "api/v1/apps"},
  { "url" => "api/v1/devices",                       "view_path" => "api/v1/devices"},
  { "url" => "api/v1/logical-numbers",               "view_path" => "api/v1/logical_numbers"},
  { "url" => "api/v1/groups",                        "view_path" => "api/v1/groups"},
  { "url" => "api/v1/parameters",                    "view_path" => "api/v1/parameters"},
  { "url" => "api/v1/assets",                        "view_path" => "api/v1/assets"},
  { "url" => "api/v1/users",                         "view_path" => "api/v1/users"},
  { "url" => "api/v1/logs",                          "view_path" => "api/v1/logs"},
  # INTEGRATION
  { "url" => "integration/architecture",             "view_path" => "integration/architecture"},
  { "url" => "integration/tcp",                      "view_path" => "integration/tcp"},
  { "url" => "integration/http",                     "view_path" => "integration/http"},
  { "url" => "integration/advanced-http",            "view_path" => "integration/advanced_http"}
]

@navigation.each do |item|
  get "/#{item["url"]}" do
    redirect "/#{current_locale}/#{item["url"]}", 301
  end
  get "/:locale/#{item["url"]}" do |locale|
    validate_locale(locale)
    erb "#{item["view_path"]}".to_sym
  end
end

# COMMANDS DESCRIPTIONS
@commands = [
  # flow
  "if", "else", "while", "break", "function", "callfunction", "execute", "exit",
  # readcard
  "getcardvariable", "system.readcard", "system.inputtransaction",
  # ui
  "menu", "menuwithheader", "displaybitmap", "display", "cleandisplay", "system.gettouchscreen",
  # print
  "print", "printbig", "printbitmap", "printbarcode", "checkpaperout", "paperfeed",
  # input
  "inputfloat", "inputformat", "inputinteger", "inputoption", "inputmoney",
  # crypto
  "crypto.crc", "crypto.encryptdecrypt", "crypto.lrc", "crypto.xor",
  # file
  "downloadfile", "filesystem.filesize", "filesystem.listfiles", "filesystem.space", "file.open", "file.close", "file.read", "file.write", "readfile", "readfilebyindex", "editfile", "deletefile",
  # iso
  "iso8583.initfieldtable", "iso8583.initmessage", "iso8583.putfield", "iso8583.endmessage", "iso8583.transactmessage", "iso8583.analyzemessage", "iso8583.getfield",
  # serialport
  "openserialport", "writeserialport", "readserialport", "closeserialport",
  # datetime
  "getdatetime", "time.calculate", "adjustdatetime",
  # conectivity
  "predial", "preconnect", "shutdownmodem", "network.checkgprssignal", "network.hostdisconnect", "network.ping", "network.send", "network.receive",
  # pinpad
  "pinpad.open", "pinpad.loadipek", "pinpad.getkey", "pinpad.getpindukpt", "pinpad.display", "pinpad.close",
  # emv
  "emv.open", "emv.loadtables", "emv.cleanstructures", "emv.adddata", "emv.getinfo", "emv.inittransaction", "emv.processtransaction", "emv.finishtransaction", "emv.removecard", "emv.settimeout", "system.readcard", "system.inputtransaction",
  # variables
  "integervariable", "stringvariable", "integerconvert", "convert.toint", "inttostring", "stringtoint", "integeroperator", "string.tohex", "string.fromhex",
  # string
  "string.charat", "string.elementat", "string.elements", "string.find", "string.getvaluebykey", "string.trim", "string.insertat", "string.length", "string.pad", "string.removeat", "string.replace", "string.replaceat", "string.substring", "substring", "joinstring", "input.getvalue",
  # smartcard
  "smartcard.insertedcard", "smartcard.closereader", "smartcard.startreader", "smartcard.transmitapdu",
  # utils
  "mathematicaloperation", "system.beep", "system.backlight", "system.checkbattery", "system.info", "system.restart", "unzipfile", "waitkey", "waitkeytimeout", "readkey", "wait"
]

@commands.each do |command|
  get "/posxml/commands/#{command}" do redirect "/#{current_locale}/posxml/commands/#{command}", 301 end
  get "/:locale/posxml/commands/#{command}" do |locale|
    validate_locale(locale)
    erb "posxml/commands/#{command}".to_sym
  end
end

get "/:locale/search" do |locale|
  validate_locale(locale)

  if params[:query]
    @results = search
  else
    redirect "/#{current_locale}/introduction", 301
  end

  erb :search
end

helpers do
  def validate_locale(url_locale)
    set_locale(url_locale) if url_locale != current_locale
  end

  def set_locale(locale = nil)
    if locale
      # Store the locale on session
      session[:locale] = locale
    elsif params[:locale]
      # Change the URL and remove last character (if ? or &)
      new_url = request.fullpath.gsub("/#{current_locale}/", "/#{params[:locale]}/").split("locale=")[0]
      new_url = new_url.chop if new_url[-1, 1] == "?" || new_url[-1, 1] == "&"

      # Store the locale on session
      session[:locale] = params[:locale]

      # Set the new locale
      I18n.locale = params[:locale]

      # Redirect to the new URL, with the new locale
      return redirect new_url
    end

    return I18n.locale = session[:locale] if session[:locale]

    I18n.locale = "pt-BR"
  end

  def current_locale
    session[:locale].nil? ? "pt-BR" : session[:locale]
  end

  def link_to(name, url)
    "<a href='/#{current_locale}/#{url}'>#{name}</a>"
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

  def option_select(value, text)
    selected = session[:locale] == value ? ' selected' : ''
    "<option value=#{value}#{selected}>#{text}</option>"
  end

  def mootit
    command = uri.split('/').last
    "<a class='moot' data-label='#{I18n.t("posxml.commands.comments_message")}' href='https://moot.it/i/cloudwalk/docs/#{command}'></a>"
  end

  def search
    uri = URI.parse(URI.encode(build_search_url))
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    raise unless res.code == "200"

    JSON.parse(res.body)
  rescue
    send_mail("Search error", "Could not perform search.\n\n#{$!.class}: #{$!.message}")
    return false
  end

  def build_search_url
    # http://domain.com/en?query=something&access-token=secret

    search_url = ENV["SEARCH_API_URL"].dup
    search_url << current_locale
    search_url << "?query=#{params[:query]}"
    search_url << "&access-token=#{ENV["SEARCH_API_TOKEN"].dup}"
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
