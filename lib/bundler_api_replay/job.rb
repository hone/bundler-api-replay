require 'net/http'
require 'uri'
require_relative '../bundler_api_replay'

class BundlerApiReplay::Job
  def initialize(request, host, port = 80)
    @request = URI.parse("http://#{request}")
    @host    = host
    @port    = port
  end

  def run
    http = Net::HTTP.new(@host, @port)
    http.request(Net::HTTP::Get.new("#{@request.path}?#{@request.query}"))
  end
end
