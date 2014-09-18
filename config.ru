require 'sinatra'
require 'sequel'
require 'sidekiq/web'
require './lib/bundler_api_replay/web'

$stdout.sync = true
JOB_TIMEOUT  = ENV['JOB_TIMEOUT'].to_i
conn         = Sequel.connect(ENV["DATABASE_URL"])

map "/sidekiq" do
  use Rack::Auth::Basic do |username, password|
    password == ENV['AUTH_PASSWORD']
  end

  run Sidekiq::Web
end

run BundlerApiReplay::Web.new(conn, JOB_TIMEOUT)
