require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_processor'

describe BundlerApiReplay::LogplexProcessor do
  let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 d.030f3924-0da0-4be1-8a33-6b476c52e3ea heroku router - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }
  let(:logplex_processor) { BundlerApiReplay::LogplexProcessor.new(input) }

  it "creates a valid object" do
    expect(logplex_processor).to be_true
  end

  it "parses out the time" do
    require 'time'

    expected_time = Time.parse("2012-11-02T20:51:42+00:00")
    expect(logplex_processor.time.utc).to eq(expected_time.utc)
  end

  it "parses out the process" do
    expect(logplex_processor.process).to eq("router")
  end

  it "parses the uuid" do
    expect(logplex_processor.uuid).to eq("d.030f3924-0da0-4be1-8a33-6b476c52e3ea")
  end

  it "parses the body" do
    expect(logplex_processor.body).to eq("GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518")
  end

  context "when it's a non-parseable line" do
    let(:input) { "oedu8204lau" }

    it "throws an exception for errors" do
      expect {logplex_processor }.to raise_error(BundlerApiReplay::LogParseError)
    end
  end

  context "new log format" do
    let(:input) { %q{271 <158>1 2013-04-23T01:07:19.030189+00:00 host heroku router - at=info method=GET path=/api/v1/dependencies?gems=termios host=bundler-api.herokuapp.com request_id=64b787daac5b76918c0a2345e503464f fwd="54.245.255.174" dyno=web.2 connect=18ms service=5ms status=200 bytes=84} }

    it "creates a valid object" do
      expect(logplex_processor).to be_true
    end
  end
end
