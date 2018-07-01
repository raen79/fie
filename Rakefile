require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'opal'
require 'opal/util'
require 'uglifier'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Build opal app'
task :build_opal do
  Opal.append_path('./lib/opal')
  Opal.append_path('./node_modules/diffhtml/dist')

  builder = Opal::Builder.new
  builder.build('fie')

  File.open('./vendor/javascript/fie.js', 'w+') do |file|
    file << Uglifier.compile(builder.to_s, mangle: true)
  end
end
