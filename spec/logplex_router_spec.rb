require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/logplex_router'

describe BundlerApiReplay::LogplexRouter do
  let(:processor) { BundlerApiReplay::LogplexRouter.new(input) }
  
  context "when using a router logplex line" do
    let(:input) { %q{at=info method=GET path=/api/v1/dependencies?gems=spoon,configuration,ffi,rspec-mocks,rspec-expectations,rspec-core,cucumber,diff-lcs,spicycode-rcov host=bundler.rubygems.org fwd="72.4.120.81" dyno=web.3 queue=0 wait=0ms connect=2ms service=41ms status=200 bytes=44571} }

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
      expect(processor.path).to eq("/api/v1/dependencies?gems=spoon,configuration,ffi,rspec-mocks,rspec-expectations,rspec-core,cucumber,diff-lcs,spicycode-rcov")
    end

    it "parses the host" do
      expect(processor.host).to eq("bundler.rubygems.org")
    end

    it "parses the fwd" do
      expect(processor.fwd).to eq("72.4.120.81")
    end

    it "parses the dyno" do
      expect(processor.dyno).to eq("web.3")
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
      expect(processor.service).to eq("41")
    end

    it "parses the status" do
      expect(processor.status).to eq("200")
    end

    it "parses the bytes" do
      expect(processor.bytes).to eq("44571")
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

  context "remove queue and wait" do
    let(:input) { %q{at=info method=GET path=/api/v1/dependencies?gems=gherkin,term-ansicolor,json_pure,net-scp,metaclass,racc,tenderlove-frex,rake-compiler,rexical,weakling host=bundler.rubygems.org request_id=c957d86bb3f25d3d77ed90942430d81a fwd="182.169.44.41" dyno=web.2 connect=0ms service=70ms status=200 bytes=51973} }

    it "creates a valid object" do
      expect(processor).to be_true
    end

    it "is from the router" do
      expect(processor.from_router?).to be_true
    end
  end
end
