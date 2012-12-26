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
  end
end
