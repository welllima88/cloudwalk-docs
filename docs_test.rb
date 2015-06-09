ENV['RACK_ENV'] = 'test'

require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rack/test'
require 'mocha/mini_test'
require_relative 'docs.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Docs" do
  before do
    # Do not deliver emails
    Pony.stubs(:deliver)
  end

  it "should redirect to index" do
    get '/'
    assert last_response.redirect?
  end

  it "should have a page for every navigation item" do
    Routes.navigation.each do |nav|
      get "/en/#{nav["url"]}"
      assert last_response.ok?, "URL /#{nav["url"]} failed (view: #{nav["view_path"]})"
    end
  end

  it "should have a page for every command item" do
    Routes.commands.each do |command|
      get "/en/posxml/commands/#{command}"
      assert last_response.ok?, "Command #{command} failed"
    end
  end

  it "should pre-select the signature paytec" do
    get '/en/walk-framework/ingenico-telium-2?signature=paytec'
    assert last_response.ok?
  end

  it "should pre-select another signature" do
    get '/en/walk-framework/ingenico-telium-2?something=else'
    assert last_response.ok?
  end

  it "should get a not found message" do
    get '/cloudwalk'
    assert last_response.not_found?, "404 failed"
  end

  it "should get a pt-BR title" do
    get '/pt-BR/introduction/authorizer'
    assert last_response.body.include?('Autorizador'), "I18n failed"
  end

  it "should get a en title" do
    get '/en/introduction/authorizer'
    assert last_response.body.include?('Authorizer'), "I18n failed"
  end

  it "should change locale to en" do
    post '/', {:url => "/pt-BR/introduction", :locale => "en"}

    follow_redirect!

    assert_equal "http://example.org/en/introduction", last_request.url
    assert last_response.ok?, "Could not change locale"
  end

  it "should change locale to pt-BR" do
    post '/', {:url => "/en/introduction", :locale => "pt-BR"}

    follow_redirect!

    assert_equal "http://example.org/pt-BR/introduction", last_request.url
    assert last_response.ok?, "Could not change locale"
  end

  it "should get a portuguese search result" do
    get '/pt-BR/search?query=posxml'
    assert last_response.ok?, "Portuguese search failed"
  end

  it "should get an english search result" do
    get '/en/search?query=posxml'
    assert last_response.ok?, "English search failed"
  end

  it "should get an empty search result" do
    query = 'kamehameha'

    get "/en/search?query=#{query}"
    assert last_response.ok?, "What? The word #{query} was found?"
  end

  it "should redirect to index due empty query" do
    get '/en/search'
    assert last_response.redirect?
  end

  it "should send a notification due a search error" do
    Net::HTTPOK.any_instance.stubs(:code).returns('500')

    get "/en/search?query=posxml"
    last_response.body.include?('Sorry for the inconvenience.')
    assert last_response.ok?
  end

  it "should not have english internal links without language" do
      result = ""
      File.open("config/locales/en.yml").each_with_index do |line, line_number|
          found = line.scan(/<a href='(\/(?!en\/)(?!pt\-BR\/)[^']*)'/)
          if found.length > 0
              result += "\tLine: #{line_number+1} URL: #{found.join("\n\t\t\t")}\n"
          end
      end

      assert result.empty?, "Found some internal links without language prefix or with wrong language prefix in file config/locales/en.yml:\n#{result}To fix this you should ensure all these links have a /en/ prefix."
  end

  it "should not have portuguese internal links in english language file" do
      result = ""
      File.open("config/locales/en.yml").each_with_index do |line, line_number|
          found = line.scan(/<a href='(\/pt\-BR\/[^']*)'/)
          if found.length > 0
              result += "\tLine: #{line_number+1} URL: #{found.join("\n\t\t\t")}\n"
          end
      end

      assert result.empty?, "Found some portuguese internal links in file config/locales/en.yml:\n#{result}To fix this you should change /pt-BR/ prefix to /en/."
  end

  it "should not have portuguese internal links without language" do
      result = ""
      File.open("config/locales/pt-br.yml").each_with_index do |line, line_number|
          found = line.scan(/<a href='(\/(?!en\/)(?!pt\-BR\/)[^']*)'/)
          if found.length > 0
              result += "\tLine: #{line_number+1} URL: #{found.join("\n\t\t\t")}\n"
          end
      end

      assert result.empty?, "Found some internal links without language prefix or with wrong language prefix in file config/locales/pt-br.yml:\n#{result}To fix this you should ensure all these links have a /pt-BR/ prefix."
  end

  it "should not have english internal links in portuguese language file" do
      result = ""
      File.open("config/locales/pt-br.yml").each_with_index do |line, line_number|
          found = line.scan(/<a href='(\/en\/[^']*)'/)
          if found.length > 0
              result += "\tLine: #{line_number+1} URL: #{found.join("\n\t\t\t")}\n"
          end
      end

      assert result.empty?, "Found some english internal links in file config/locales/pt-br.yml:\n#{result}To fix this you should change /en/ prefix to /pt-BR/."
  end
end
