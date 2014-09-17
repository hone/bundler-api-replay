require 'sinatra'
require 'sequel'
require './lib/bundler_api_replay/web'

$stdout.sync              = true
Thread.abort_on_exception = true

JOB_TIMEOUT = ENV['JOB_TIMEOUT'].to_i

conn = Sequel.connect(ENV["DATABASE_URL"])
run BundlerApiReplay::Web.new(conn, JOB_TIMEOUT)
