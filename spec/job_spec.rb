require 'artifice'
require 'sinatra/base'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/job'

describe BundlerApiReplay::Job do
  class CheckPath < Sinatra::Base
    get "/blargh" do
      params[:gems] == "boo" ? "sgb" : "sbb"
    end
  end

  let(:request) { "foo.com/blargh?gems=boo" }
  let(:host) { 'localhost' }

  it "runs the job" do
    job      = BundlerApiReplay::Job.new(request, host)
    response = nil

    Artifice.activate_with(CheckPath) do
      response = job.run
    end

    expect(response.body).to eq("sgb")
  end
end
