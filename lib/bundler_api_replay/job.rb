require 'net/http'
require 'uri'
require_relative '../bundler_api_replay'

class BundlerApiReplay::Job
  def initialize(request, host, port = nil)
    @request = URI.parse("http://#{request}")
    @host    = host
    @port    = port

    if @port.nil?
      @request.scheme == "https" ? @port = 443 : @port = 80
    end
  end

  def run
    http = Net::HTTP.new(@host, @port)
    http.request(Net::HTTP::Get.new("#{@request.path}?#{@request.query}"))
  end
end
