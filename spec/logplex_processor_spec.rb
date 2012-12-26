require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_processor'

describe BundlerApiReplay::LogplexProcessor do
  let(:logplex_processor) { BundlerApiReplay::LogplexProcessor.new(input) }

  context "when it's a router log line" do
    let(:input) { "2012-12-22T04:41:31+00:00 heroku[router]: at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,git,metaclass,net-ssh,SexpProcessor,test-unit host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.4 queue=0 wait=0ms connect=2ms service=13ms status=200 bytes=7118" }

    it "creates a valid object" do
      expect(logplex_processor).to be_true
    end

    it "parses out the time" do
      require 'time'

      expected_time = Time.parse("2012-12-22T04:41:31+00:00")
      expect(logplex_processor.time.utc).to eq(expected_time.utc)
    end

    it "parses out the process" do
      expect(logplex_processor.process).to eq("router")
    end

    it "parses the body" do
      expect(logplex_processor.body).to eq("at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,git,metaclass,net-ssh,SexpProcessor,test-unit host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.4 queue=0 wait=0ms connect=2ms service=13ms status=200 bytes=7118")
    end
  end

  context "when it's an app log line" do
    let(:input) { %q{2012-12-26T18:12:38+00:00 app[web.4]: 72.4.120.81 - - [26/Dec/2012 18:12:38] "GET /api/v1/dependencies?gems=mhennemeyer-output_catcher,peterwald-git,schacon-git,tenderlove-frex,relevance-rcov,mojombo-chronic,rspec_junit_formatter,mislav-will_paginate,mongodb-mongo,spicycode-rcov,faraday,hashie,multi_xml,yajl-ruby,net-http-digest_auth HTTP/1.1" 200 9955 0.0109} }

    it "creates a valid object" do
      expect(logplex_processor).to be_true
    end

    it "parses out the time" do
      require 'time'

      expected_time = Time.parse("2012-12-26T18:12:38+00:00")
      expect(logplex_processor.time.utc).to eq(expected_time.utc)
    end

    it "parses out the process" do
      expect(logplex_processor.process).to eq("web.4")
    end

    it "parses the body" do
      expect(logplex_processor.body).to eq(%q{72.4.120.81 - - [26/Dec/2012 18:12:38] "GET /api/v1/dependencies?gems=mhennemeyer-output_catcher,peterwald-git,schacon-git,tenderlove-frex,relevance-rcov,mojombo-chronic,rspec_junit_formatter,mislav-will_paginate,mongodb-mongo,spicycode-rcov,faraday,hashie,multi_xml,yajl-ruby,net-http-digest_auth HTTP/1.1" 200 9955 0.0109})
    end
  end

  context "when it's a non-parseable line" do
    let(:input) { "oedu8204lau" }

    it "throws an exception for errors" do
      expect {logplex_processor }.to raise_error(BundlerApiReplay::LogParseError)
    end
  end
end
