require 'sinatra/base'
require 'logger'
require_relative '../bundler_api_replay'
require_relative 'logplex_processor'
require_relative 'logplex_router'
require_relative 'job'
require_relative 'store_job'

class BundlerApiReplay::Web < Sinatra::Base
  use Rack::Auth::Basic do |username, password|
    password == ENV['AUTH_PASSWORD']
  end

  def initialize(pool, conn)
    super()

    @pool   = pool
    @conn   = conn
    @sites  = sites
    @logger = Logger.new(STDOUT)
  end

  post "/logs" do
    @logger.info("Pool Size: #{@pool.queue_size}")
    @logger.info("Sites: #{@sites}")

    payload = request.body.read
    body    = BundlerApiReplay::LogplexProcessor.new(payload)
    lr      = BundlerApiReplay::LogplexRouter.new(body.body)

    if lr.from_router?
      @sites.each do |site|
        host = site[:host]
        port = site[:port]
        job  = BundlerApiReplay::Job.new(lr.path, host, port)
        @logger.info("Job Enqueued: http://#{job.host}:#{job.port}#{job.path}")
        @pool.enq(job)
      end
    end

    ""
  end

  get "/test" do
    "OK"
  end

  post "/test" do
    "OK"
  end

  private
  def sites
    @conn[:sites].all
  end
end
