require_relative '../bundler_api_replay'

class BundlerApiReplay::StoreJob
  attr_reader :path, :host, :port

  def initialize(conn, path, host, port = 80)
    @conn = conn
    @path = path
    @host = host
    @port = port
  end

  def run
    @conn[:requests].insert(
      path: @path,
      host: @host,
      port: @port,
    )
  end
end
