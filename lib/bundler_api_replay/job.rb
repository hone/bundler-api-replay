require 'net/http'
require 'zlib'
require 'sidekiq'
require_relative '../bundler_api_replay'
require_relative '../../config/sidekiq'

class BundlerApiReplay::Job
  include Sidekiq::Worker

  def perform(path, host, port = 80, timeout = 5)
    logger = Logger.new(STDOUT)
    http   = Net::HTTP.new(host, port)
    http.read_timeout = timeout
    http.request(Net::HTTP::Get.new(path))
  rescue EOFError, Zlib::Error, Net::ReadTimeout => e
    # Bad responses from crashed hosts raise an EOFError.
    #   https://gist.github.com/lmarburger/9d063165e57743987a92
    logger.warn e.message
  end
end
