require 'sinatra'
require 'sequel'
require './lib/bundler_api_replay/web'
require './lib//bundler_api/consumer_pool'

$stdout.sync              = true
Thread.abort_on_exception = true

NUM_THREADS = ENV['THREADS'].to_i
JOB_TIMEOUT = ENV['TIMEOUT'].to_i

pool  = BundlerApi::ConsumerPool.new(NUM_THREADS, JOB_TIMEOUT)

pool.start

web    = Thread.new {
  conn = Sequel.connect(ENV["DATABASE_URL"])
  run BundlerApiReplay::Web.new(pool, conn)
}
web.join

at_exit do
  pool.poison
  pool.join
end
