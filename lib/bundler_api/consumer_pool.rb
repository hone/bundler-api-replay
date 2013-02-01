require 'thread'

module BundlerApi
  class ConsumerPool
    POISON = :poison

    attr_reader :queue

    def initialize(size)
      @size    = size
      @queue   = Queue.new
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

          job.run
        end
      }
    end
  end
end
