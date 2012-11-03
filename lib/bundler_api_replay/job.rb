require 'net/http'
require_relative '../bundler_api_replay'

class BundlerApiReplay::Job
  def initialize(request, host, port = 80)
    @request = request
    @host    = host
    @port    = port
  end

  def run
    http = Net::HTTP.new(@host, @port)
    http.request(Net::HTTP::Get.new("#{@request.path}#{@request.query}"))
  end
end
