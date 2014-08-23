require 'sinatra/base'
require 'logger'
require_relative '../bundler_api_replay'
require_relative 'logplex_processor'
require_relative 'logplex_router'
require_relative 'job'

class BundlerApiReplay::Web < Sinatra::Base
  use Rack::Auth::Basic do |username, password|
    password == ENV['AUTH_PASSWORD']
  end

  def initialize(pool, conn, timeout)
    super()

    @pool    = pool
    @conn    = conn
    @sites   = sites
    @timeout = timeout
    @logger  = Logger.new(STDOUT)
    @logger.info("Sites: #{@sites}")
  end

  post "/logs" do
    @logger.info("Pool Size: #{@pool.queue_length}")

    payload = request.body.read
    begin
      body    = BundlerApiReplay::LogplexProcessor.new(payload)
      lr      = BundlerApiReplay::LogplexRouter.new(body.body)

      if lr.from_router?
        @sites.each do |site|
          host = site[:host]
          port = site[:port]
          job = BundlerApiReplay::Job.new(lr.path, host, port, @timeout)
          @pool << job.to_proc
          @logger.info("Job Enqueued: http://#{job.host}:#{job.port}#{job.path}")
        end
      end
    rescue BundlerApiReplay::LogParseError => e
      $stderr.puts e.message
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
    @conn[:sites].where(:on => true).all
  end
end
