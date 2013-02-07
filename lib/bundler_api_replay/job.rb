require 'net/http'
require_relative '../bundler_api_replay'

class BundlerApiReplay::Job
  attr_reader :path, :host, :port

  def initialize(path, host, port = 80)
    @path = path
    @host = host
    @port = port
  end

  def run
    http = Net::HTTP.new(@host, @port)
    http.request(Net::HTTP::Get.new(@path))
  rescue EOFError => e
    # Bad responses from crashed hosts raise an EOFError.
    #   https://gist.github.com/lmarburger/9d063165e57743987a92
    logger.warn "EOFError: #{to_s}"
  end

  def to_s
    "BundlerApiReplay::Job: path: #{@path}, port: #{@port}, host: #{@host}"
  end

  def logger(io = STDOUT)
    @logger ||= Logger.new(io)
  end
end
