require 'time'
require_relative '../bundler_api_replay'

class BundlerApiReplay::LogplexProcessor
  LineRegex = /^\d+ \<\d+\>1 (\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\+00:00) [a-z0-9-]+ ([a-z0-9\-\_\.]+) ([a-z0-9\-\_\.]+) \- (.*)$/

  attr_reader :time, :process, :uuid, :body

  def initialize(input)
    @input     = input
    match_data = LineRegex.match(input)

    @time    = Time.parse(match_data[1])
    @process = match_data[2]
    @uuid    = match_data[3]
    @body    = match_data[4]
  end
end
