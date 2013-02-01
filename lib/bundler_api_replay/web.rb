require 'sinatra/base'
require 'logger'
require_relative '../bundler_api_replay'
require_relative 'logplex_router'
require_relative 'job'
require_relative 'store_job'

class BundlerApiReplay::Web < Sinatra::Base
  def initialize(pool, conn)
    super()

    @pool   = pool
    @conn   = conn
    @sites  = sites
    @logger = Logger.new(STDOUT)
  end

  post "/logs" do
    @logger.info("Pool Size: #{@pool.queue_size}")

    body = request.body.read
    lr   = BundlerApiReplay::LogplexRouter.new(body)

    if lr.from_router?
      request = lr.request

      @sites.each do |site|
        host = site[:host]
        port = site[:port]
        job  = BundlerApiReplay::Job.new(request, host, port)
        @logger.info("Job Enqueued: http://#{job.host}:#{job.port}#{job.path}")
        @pool.enq(job)
        if @conn
          @logger.info("StoreJob Enqueued: http://#{job.host}:#{job.port}#{job.path}")
          db_job = BundlerApiReplay::StoreJob.new(@conn, request, host, port)
          @pool.enq(db_job)
        end
      end
    end

    ""
  end

  private
  def sites
    @conn[:sites].all
  end
end
