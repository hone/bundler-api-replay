$stdout.sync = true

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w(-fs --color)
    t.ruby_opts  = %w(-w)
  end
rescue LoadError => e
end
