require 'time'
require_relative '../bundler_api_replay'

class BundlerApiReplay::LogplexProcessor
  LineRegex = %r{
    (?<time>\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\+00:00){0}
    (?<process>[a-z0-9\-\_\.]+){0}
    (?<body>.*){0}

    ^\g<time>\s(heroku|app)\[\g<process>\]:\s\g<body>$
  }x

  attr_reader :time, :process, :body

  def initialize(input)
    @input     = input
    match_data = LineRegex.match(input)

    @time    = Time.parse(match_data[:time])
    @process = match_data[:process]
    @body    = match_data[:body]
  end
end
