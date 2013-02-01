require 'rack/test'
require 'sequel'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/web'
require_relative '../lib/bundler_api/consumer_pool'

describe BundlerApiReplay::Web do
  include Rack::Test::Methods

  let(:pool) { BundlerApi::ConsumerPool.new(1) }
  let(:sites) { [['localhost', 80]] }

  def app
    BundlerApiReplay::Web.new(pool, sites, conn)
  end

  context "when a db connection is used" do
    let(:conn) { Sequel.connect(ENV["TEST_DATABASE_URL"]) }

    context "post /logs" do
      context "when a router log" do
        let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 heroku router d.030f3924-0da0-4be1-8a33-6b476c52e3ea - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }

        it "enqueues jobs if a router request" do
          post "/logs", input

          expect(pool.queue_size).to eq(2)
          expect(last_response.status).to eq(200)
        end
      end

      context "when a sinatra log" do
        let(:input) { %q{348 <13>1 2012-11-04T08:37:34+00:00 app web.2 d.030f3924-0da0-4be1-8a33-6b476c52e3ea - 72.4.120.81 - - [04/Nov/2012 08:37:34] "GET /api/v1/dependencies?gems=rails,devise,sqlite3,sass-rails,coffee-rails,uglifier,jquery-rails,rails-backbone,powder,awesome_print,annotate,jasmine-headless-webkit,jasmine,jasminerice,rspec-rails HTTP/1.1" 200 93127 0.1165"} }

        it "does not enqueue a job" do
          post "/logs", input

          expect(pool.queue_size).to eq(0)
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  context "when db connection is used" do
    let(:conn) { nil }

    context "post /logs" do
      context "when a router log" do
        let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 heroku router d.030f3924-0da0-4be1-8a33-6b476c52e3ea - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }

        it "enqueues jobs if a router request" do
          post "/logs", input

          expect(pool.queue_size).to eq(1)
          expect(last_response.status).to eq(200)
        end
      end

      context "when a sinatra log" do
        let(:input) { %q{348 <13>1 2012-11-04T08:37:34+00:00 app web.2 d.030f3924-0da0-4be1-8a33-6b476c52e3ea - 72.4.120.81 - - [04/Nov/2012 08:37:34] "GET /api/v1/dependencies?gems=rails,devise,sqlite3,sass-rails,coffee-rails,uglifier,jquery-rails,rails-backbone,powder,awesome_print,annotate,jasmine-headless-webkit,jasmine,jasminerice,rspec-rails HTTP/1.1" 200 93127 0.1165"} }

        it "does not enqueue a job" do
          post "/logs", input

          expect(pool.queue_size).to eq(0)
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
