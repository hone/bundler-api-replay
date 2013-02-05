require 'rack/test'
require 'sequel'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/web'
require_relative '../lib/bundler_api/consumer_pool'

describe BundlerApiReplay::Web do
  include Rack::Test::Methods

  let(:pool) { BundlerApi::ConsumerPool.new(1) }
  let(:host) { 'localhost' }
  let(:port) { 80 }
  let(:conn) { Sequel.connect(ENV["TEST_DATABASE_URL"]) }
  before do
    conn[:sites].insert(
      host: host,
      port: port
    )
  end
  around(:each) do |example|
    conn.transaction(:rollback => :always) { example.run }
  end

  def app
    BundlerApiReplay::Web.new(pool, conn)
  end

  context "post /logs" do
    context "when authorized" do
      let(:password) { 'omg' }

      before do
        ENV['AUTH_PASSWORD'] = password
        authorize '', password
      end

      context "when a router log" do
        let(:input) { "2012-12-26T18:12:38+00:00 heroku[router]: at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,net-ssh,linecache host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.11 queue=0 wait=0ms connect=1ms service=11ms status=200 bytes=5613" }

        it "enqueues jobs if a router request" do
          post "/logs", input

          expect(pool.queue_size).to eq(2)
          expect(last_response.status).to eq(200)

          replay_job = pool.queue.pop
          store_job  = pool.queue.pop
          expect(replay_job).to be_a(BundlerApiReplay::Job)
          expect(store_job).to be_a(BundlerApiReplay::StoreJob)
          [replay_job, store_job].each do |job|
            expect(job.host).to eq(host)
            expect(job.port).to eq(port)
            expect(job.path).to eq("/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,net-ssh,linecache")
          end
        end
      end

      context "when a sinatra log" do
        let(:input) { %q{2012-12-26T18:12:38+00:00 app[web.4]: 72.4.120.81 - - [26/Dec/2012 18:12:38] "GET /api/v1/dependencies?gems=mhennemeyer-output_catcher,peterwald-git,schacon-git,tenderlove-frex,relevance-rcov,mojombo-chronic,rspec_junit_formatter,mislav-will_paginate,mongodb-mongo,spicycode-rcov,faraday,hashie,multi_xml,yajl-ruby,net-http-digest_auth HTTP/1.1" 200 9955 0.0109} }

        it "does not enqueue a job" do
          post "/logs", input

          expect(pool.queue_size).to eq(0)
          expect(last_response.status).to eq(200)
        end
      end
    end

    context "when not authorized" do
      let(:input) { "2012-12-26T18:12:38+00:00 heroku[router]: at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,net-ssh,linecache host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.11 queue=0 wait=0ms connect=1ms service=11ms status=200 bytes=5613" }

      it "doesn't let you push jobs to the queue" do
        post "/logs", input

        expect(last_response.status).to eq(401)
        expect(pool.queue_size).to eq(0)
      end
    end
  end
end
