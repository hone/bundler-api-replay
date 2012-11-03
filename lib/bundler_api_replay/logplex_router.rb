require_relative 'logplex_processor'

class BundlerApiReplay::LogplexRouter < BundlerApiReplay::LogplexProcessor
  RouterRegex = %r{
    (?<method>GET|POST){0}
    (?<request>.*){0}
    (?<dyno>[a-zA-Z]+[.][0-9]+){0}
    (?<queue>\d+){0}
    (?<wait>\d+){0}
    (?<service>\d+){0}
    (?<status>\d+){0}
    (?<bytes>\d+){0}

    ^\g<method>\s\g<request>\sdyno=\g<dyno>\squeue=\g<queue>\swait=\g<wait>ms\sservice=\g<service>ms\sstatus=\g<status>\sbytes=\g<bytes>$
  }x

  attr_reader :method, :request, :dyno, :queue, :wait, :service, :status, :bytes

  def initialize(input)
    super(input)

    md = RouterRegex.match(@body)
    @method  = md[:method]
    @request = md[:request]
    @dyno    = md[:dyno]
    @queue   = md[:queue]
    @wait    = md[:wait]
    @service = md[:service]
    @status  = md[:status]
    @bytes   = md[:bytes]
  end
end
