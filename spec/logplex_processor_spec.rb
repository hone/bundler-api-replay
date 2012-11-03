require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_processor'

describe BundlerApiReplay::LogplexProcessor do
  let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 heroku router d.030f3924-0da0-4be1-8a33-6b476c52e3ea - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }
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
end
