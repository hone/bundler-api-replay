require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_router'

describe BundlerApiReplay::LogplexRouter do
  let(:processor) { BundlerApiReplay::LogplexRouter.new(input) }
  
  context "when using a router logplex line" do
    let(:input) { "2012-12-22T04:41:31+00:00 heroku[router]: at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,git,metaclass,net-ssh,SexpProcessor,test-unit host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.4 queue=0 wait=0ms connect=2ms service=13ms status=200 bytes=7118" }

    it "creates a valid object" do
      expect(processor).to be_true
    end

    it "is from the router" do
      expect(processor.from_router?).to be_true
    end

    it "parses the request method" do
      expect(processor.method).to eq("GET")
    end

    it "parses the path" do
      expect(processor.path).to eq("/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,git,metaclass,net-ssh,SexpProcessor,test-unit")
    end

    it "parses the host" do
      expect(processor.host).to eq("bundler-api.herokuapp.com")
    end

    it "parses the fwd" do
      expect(processor.fwd).to eq("72.4.120.81")
    end

    it "parses the dyno" do
      expect(processor.dyno).to eq("web.4")
    end

    it "parses the queue" do
      expect(processor.queue).to eq("0")
    end

    it "parses the wait" do
      expect(processor.wait).to eq("0")
    end

    it "parses the connect" do
      expect(processor.connect).to eq("2")
    end

    it "parses the service" do
      expect(processor.service).to eq("13")
    end

    it "parses the status" do
      expect(processor.status).to eq("200")
    end

    it "parses the bytes" do
      expect(processor.bytes).to eq("7118")
    end
  end

  context "when using a non router logplex line" do
    let(:input) { %q{2012-12-22T04:45:19+00:00 app[web.9]: 72.4.120.81 - - [22/Dec/2012 04:45:19] "GET /api/v1/dependencies.json?gems=sso-auth HTTP/1.1" 200 1073 0.0078} }

    it "creates a valid object" do
      expect(processor).to be_true
    end

    it "is not from_router" do
      expect(processor.from_router?).to be_false
    end
  end
end
