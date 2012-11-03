require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_router'

describe BundlerApiReplay::LogplexRouter do
  let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 heroku router d.030f3924-0da0-4be1-8a33-6b476c52e3ea - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }
  let(:processor) { BundlerApiReplay::LogplexRouter.new(input) }

  it "creates a valid object" do
    expect(processor).to be_true
  end

  it "parses the request method" do
    expect(processor.method).to eq("GET")
  end

  it "parses the request" do
    expect(processor.request).to eq("bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest")
  end

  it "parses the dyno" do
    expect(processor.dyno).to eq("web.5")
  end

  it "parses the queue" do
    expect(processor.queue).to eq("0")
  end

  it "parses the wait" do
    expect(processor.wait).to eq("0")
  end

  it "parses the service" do
    expect(processor.service).to eq("27")
  end

  it "parses the status" do
    expect(processor.status).to eq("200")
  end

  it "parses the bytes" do
    expect(processor.bytes).to eq("8518")
  end
end
