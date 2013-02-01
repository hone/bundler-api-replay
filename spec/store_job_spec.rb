require 'sequel'
require_relative 'spec_helper'
require_relative '../lib/bundler_api_replay/store_job'

describe BundlerApiReplay::StoreJob do
  let(:conn) { Sequel.connect(ENV["TEST_DATABASE_URL"]) }
  let(:path) { "/foo" }
  let(:host) { 'localhost' }
  around(:each) do |example|
    conn.transaction(:rollback => :always) { example.run }
  end

  it "runs the job" do
    job    = BundlerApiReplay::StoreJob.new(conn, path, host)

    expect { result }.not_to raise_error(Sequel::DatabaseError)
  end
end
