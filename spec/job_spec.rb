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

  let(:path) { "/blargh?gems=boo" }
  let(:host) { 'localhost' }

  it "runs the job" do
    response = nil

    Artifice.activate_with(CheckPath) do
      response = BundlerApiReplay::Job.new.perform(path: path, host: host)
    end

    expect(response.body).to eq("sgb")
  end
end
