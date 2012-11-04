require 'rack/test'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/web'
require_relative '../lib/bundler_api/consumer_pool'

describe BundlerApiReplay::Web do
  include Rack::Test::Methods

  let(:pool) { BundlerApi::ConsumerPool.new(1) }
  let(:sites) { [['localhost', 80]] }
  let(:input) { "339 <158>1 2012-11-02T20:51:42+00:00 heroku router d.030f3924-0da0-4be1-8a33-6b476c52e3ea - GET bundler-api.herokuapp.com/api/v1/dependencies?gems=SexpProcessor,oauth2,roauth,ruby_core_source,simple_oauth,windows-api,win32-api,bones-rcov,bones-rubyforge,bones-rspec,bones-zentest dyno=web.5 queue=0 wait=0ms service=27ms status=200 bytes=8518" }

  def app
    BundlerApiReplay::Web.new(pool, sites)
  end

  context "post /logs" do
    it "enqueues jobs" do
      post "/logs", input

      expect(pool.queue_size).to eq(1)
    end
  end
end
