require 'net/http'
require 'uri'
require_relative '../bundler_api_replay'

class BundlerApiReplay::Job
  def initialize(request, host, port = 80)
    @request = request
    @host    = host
    @port    = port
  end

  def run
    uri  = URI.parse(@request)
    http = Net::HTTP.new(@host, @port)
    http.request(Net::HTTP::Get.new("#{uri.path}#{uri.query}"))
  end
end
