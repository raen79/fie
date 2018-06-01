require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'opal'
require 'opal/util'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Build opal app'
task :build do
  Opal.append_path('./lib/opal')
  Opal.append_path('./node_modules/diffhtml/dist')

  builder = Opal::Builder.new
  builder.build('fie')

  File.open('./vendor/javascript/fie.js', 'w+') do |file|
    file << Opal::Util.uglify(builder.to_s)
  end
end