require 'sinatra'
require 'sequel'
require 'concurrent'
require './lib/bundler_api_replay/web'

$stdout.sync              = true
Thread.abort_on_exception = true

NUM_THREADS = ENV['THREADS'].to_i
JOB_TIMEOUT = ENV['JOB_TIMEOUT'].to_i

pool   = Concurrent::FixedThreadPool.new(NUM_THREADS)
web    = Thread.new {
  conn = Sequel.connect(ENV["DATABASE_URL"])
  run BundlerApiReplay::Web.new(pool, conn, JOB_TIMEOUT)
}
web.join

at_exit do
  pool.shutdown
  pool.wait_for_termination
end
