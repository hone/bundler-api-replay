require 'sinatra/base'
require_relative '../bundler_api_replay'
require_relative 'logplex_router'
require_relative 'job'

class BundlerApiReplay::Web < Sinatra::Base
  def initialize(pool, sites)
    super()

    @pool  = pool
    @sites = sites
  end

  post "/logs" do
    body = request.body.read
    lr   = BundlerApiReplay::LogplexRouter.new(body)

    if lr.from_router?
      request = lr.request

      @sites.each do |host, port|
        job = BundlerApiReplay::Job.new(request, host, port)
        @pool.enq(job)
      end
    end

    ""
  end
end
