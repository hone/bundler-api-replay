require 'sinatra'

$stdout.sync = true

post "/logs" do
  logger.info(request.body.read)
end

run Sinatra::Application
