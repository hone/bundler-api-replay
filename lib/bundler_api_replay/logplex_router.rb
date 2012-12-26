require_relative 'logplex_processor'

class BundlerApiReplay::LogplexRouter < BundlerApiReplay::LogplexProcessor
  RouterRegex = %r{
    (?<method>GET|POST){0}
    (?<path>.*){0}
    (?<host>.*){0}
    (?<fwd>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}){0}
    (?<dyno>[a-zA-Z]+[.][0-9]+){0}
    (?<queue>\d+){0}
    (?<wait>\d+){0}
    (?<connect>\d+){0}
    (?<service>\d+){0}
    (?<status>\d+){0}
    (?<bytes>\d+){0}

    ^at=info\smethod=\g<method>\spath=\g<path>\shost=\g<host>\sfwd=\g<fwd>\sdyno=\g<dyno>\squeue=\g<queue>\swait=\g<wait>ms\sconnect=\g<connect>ms\sservice=\g<service>ms\sstatus=\g<status>\sbytes=\g<bytes>$
  }x

  attr_reader :method, :path, :host, :fwd, :dyno, :queue, :wait, :connect, :service, :status, :bytes

  def initialize(input)
    super(input)

    md = RouterRegex.match(@body)
    if md
      @match   = true
      @method  = md[:method]
      @path    = md[:path]
      @host    = md[:host]
      @fwd     = md[:fwd]
      @dyno    = md[:dyno]
      @queue   = md[:queue]
      @wait    = md[:wait]
      @connect = md[:connect]
      @service = md[:service]
      @status  = md[:status]
      @bytes   = md[:bytes]
    else
      @match = false
    end
  end

  def from_router?
    @match
  end
end
