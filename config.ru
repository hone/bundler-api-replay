require 'sinatra'
require './lib/bundler_api_replay/web'
require './lib//bundler_api/consumer_pool'

$stdout.sync              = true
Thread.abort_on_exception = true

NUM_THREADS = 3

pool  = BundlerApi::ConsumerPool.new(NUM_THREADS)
sites = [[ENV['DEST_HOST'], ENV['DEST_PORT']]]

pool.start

web    = Thread.new { run BundlerApiReplay::Web.new(pool, sites) }
web.join

at_exit do
  pool.poison
  pool.join
end
