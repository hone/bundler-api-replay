require 'sinatra/base'
require 'logger'
require_relative '../bundler_api_replay'
require_relative 'logplex_router'
require_relative 'job'
require_relative 'store_job'

class BundlerApiReplay::Web < Sinatra::Base
  def initialize(pool, sites, conn)
    super()

    @pool   = pool
    @sites  = sites
    @logger = Logger.new(STDOUT)
    @conn   = conn
  end

  post "/logs" do
    @logger.info("Pool Size: #{@pool.queue_size}")

    body = request.body.read
    lr   = BundlerApiReplay::LogplexRouter.new(body)

    if lr.from_router?
      request = lr.request

      @sites.each do |host, port|
        job = BundlerApiReplay::Job.new(request, host, port)
        @logger.info("Job Enqueued: http://#{job.host}:#{job.port}#{job.path}")
        @pool.enq(job)
        if @conn
          db_job = BundlerApiReplay::StoreJob.new(@conn, request, host, port)
          @pool.enq(db_job)
        end
      end
    end

    ""
  end
end
