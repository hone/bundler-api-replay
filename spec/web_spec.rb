require 'rack/test'
require 'sequel'
require 'sidekiq/testing'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/web'

Sidekiq::Testing.fake!

describe BundlerApiReplay::Web do
  include Rack::Test::Methods

  let(:host)    { 'localhost' }
  let(:timeout) { 5 }
  let(:port)    { 80 }
  let(:conn)    { Sequel.connect(ENV["TEST_DATABASE_URL"]) }
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
    BundlerApiReplay::Web.new(conn, timeout)
  end

  context "post /logs" do
    context "when authorized" do
      let(:password) { 'omg' }

      before do
        ENV['AUTH_PASSWORD'] = password
        authorize '', password
      end

      context "when a router log" do
        let(:input) { %q{453 <158>1 2013-02-05T02:05:20+00:00 d.615f2863-24cc-41b4-85c5-1466dc514218 heroku router - at=info method=GET path="/api/v1/dependencies?gems=haml,bones,terminal-table,lumberjack,pry,sys-uname,growl,libnotify,bundler,open_gem,win32-open3,test-spec,camping,fcgi,memcache-client,mongrel,ruby-openid,thin,json,win32-api,therubyracer" host=bundler-api.herokuapp.com fwd=54.245.255.174 dyno=web.2 queue=0 wait=0ms connect=3ms service=99ms status=200 bytes=123176} }

        it "enqueues jobs if a router request" do
          expect {
            post "/logs", input
          }.to change(BundlerApiReplay::Job.jobs, :size).by(1)

          expect(last_response.status).to eq(200)
        end
      end

      context "when a postgres log" do
        let(:input) { %q{245 <134>1 2013-02-05T03:12:18+00:00 app postgres d.615f2863-24cc-41b4-85c5-1466dc514218 - [23799-1] uevm0cffc58fgd [TEAL] LOG:  duration: 54.447 ms  statement:       SELECT rv.name, rv.number, rv.platform, d.requirements, for_dep_name.name dep_name} }

        it "does not enqueue a job" do
          expect {
            post "/logs", input
          }.not_to change(BundlerApiReplay::Job.jobs, :size)

          expect(last_response.status).to eq(200)
        end
      end
    end

    context "when not authorized" do
      let(:input) { "2012-12-26T18:12:38+00:00 heroku[router]: at=info method=GET path=/api/v1/dependencies?gems=bones-rcov,bones-rubyforge,bones-rspec,bones-zentest,net-ssh,linecache host=bundler-api.herokuapp.com fwd=72.4.120.81 dyno=web.11 queue=0 wait=0ms connect=1ms service=11ms status=200 bytes=5613" }

      it "doesn't let you push jobs to the queue" do
        expect {
          post "/logs", input
        }.not_to change(BundlerApiReplay::Job.jobs, :size)

        expect(last_response.status).to eq(401)
      end
    end
  end
end
