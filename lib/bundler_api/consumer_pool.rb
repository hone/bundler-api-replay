require 'thread'
require 'timeout'
require 'logger'

module BundlerApi
  class ConsumerPool
    POISON = :poison

    attr_reader :queue

    def initialize(size, timeout = 0, logger = Logger.new(STDOUT))
      @size    = size
      @queue   = Queue.new
      @logger  = logger
      @timeout = timeout
      @threads = []
    end

    def enq(job)
      @queue.enq(job)
    end

    def start
      @size.times { @threads << create_thread }
    end

    def join
      @threads.each {|t| t.join }
    end

    def poison
      @size.times { @queue.enq(POISON) }
    end

    def queue_size
      @queue.size
    end

    private
    def create_thread
      Thread.new {
        loop do
          job = @queue.deq
          break if job == POISON

          begin
            Timeout.timeout(@timeout) do
              job.run
            end
          rescue Timeout::Error => e
            @logger.info("Job timed out: #{job.to_s}")
          end
        end
      }
    end
  end
end
