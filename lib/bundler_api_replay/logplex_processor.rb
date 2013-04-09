require 'time'
require_relative '../bundler_api_replay'
require_relative 'errors'

class BundlerApiReplay::LogplexProcessor
  LineRegex = %r{
    (?<time>\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d{6})?\+00:00){0}
    (?<process>[a-z0-9\-\_\.]+){0}
    (?<uuid>[a-z0-9\-\_\.]+){0}
    (?<body>.*){0}

    ^\d+\s\<\d+\>1\s\g<time>\s[a-z0-9-]+\s\g<process>\s\g<uuid>\s\-\s\g<body>$
  }x

  attr_reader :time, :process, :uuid, :body

  def initialize(input)
    @input     = input
    match_data = LineRegex.match(input)
    if match_data
      @time    = Time.parse(match_data[:time])
      @process = match_data[:process]
      @uuid    = match_data[:uuid]
      @body    = match_data[:body]
    else
      raise BundlerApiReplay::LogParseError.new("Could not parse: #{input}")
    end
  end
end
