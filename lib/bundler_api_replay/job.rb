require 'net/http'
require 'zlib'
require 'sidekiq'
require_relative '../bundler_api_replay'
require_relative '../../config/sidekiq'

class BundlerApiReplay::Job
  include Sidekiq::Worker

  def perform(path: , host: , port: 80, logger: Logger.new(STDOUT), timeout: 5)
    http = Net::HTTP.new(host, port)
    http.request(Net::HTTP::Get.new(path))
  rescue EOFError, Zlib::Error => e
    # Bad responses from crashed hosts raise an EOFError.
    #   https://gist.github.com/lmarburger/9d063165e57743987a92
    logger.warn "EOFError: #{to_s}"
  end
end
