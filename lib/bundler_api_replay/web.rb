require 'sinatra/base'
require 'logger'
require_relative '../bundler_api_replay'
require_relative 'logplex_router'
require_relative 'job'

class BundlerApiReplay::Web < Sinatra::Base
  def initialize(pool, sites)
    super()

    @pool   = pool
    @sites  = sites
    @logger = Logger.new(STDOUT)
  end

  post "/logs" do
    @logger.info("Pool Size: #{@pool.queue_size}")

    body = request.body.read
    lr   = BundlerApiReplay::LogplexRouter.new(body)

    if lr.from_router?
      request = lr.request

      @sites.each do |host, port|
        job = BundlerApiReplay::Job.new("http://#{request}", host, port)
        @pool.enq(job)
      end
    end

    ""
  end
end
