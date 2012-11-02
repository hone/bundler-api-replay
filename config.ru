require 'sinatra'

$stdout.sync = true

post "/logs" do
  logger.info(body)
end

run Sinatra::Application
