ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rack/test'
require_relative 'docs.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Docs" do
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

  it "should get a not found message" do
    get '/cloudwalk'
    assert last_response.not_found?, "404 failed"
  end

  it "should get a pt-BR title" do
    get '/pt-BR/introduction'
    assert last_response.body.include?('Visão geral do serviço CloudWalk'), "I18n failed"
  end

  it "should get a en title" do
    get '/en/introduction'
    assert last_response.body.include?('CloudWalk Service Overview'), "I18n failed"
  end
end
