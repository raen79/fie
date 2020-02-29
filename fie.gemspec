lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fie/version'

Gem::Specification.new do |spec|
  spec.name          = 'fie'
  spec.version       = Fie::VERSION
  spec.authors       = ['Eran Peer']
  spec.email         = ['eran.peer79@gmail.com']

  spec.summary       = %q{Fie is a Rails-centric frontend framework running over a permanent WebSocket connection.}
  spec.metadata      = { "source_code_uri" => "https://github.com/raen79/fie" }
  spec.homepage      = 'https://fie.eranpeer.co'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{bin,lib,vendor}/**/*") + %w(LICENSE README.md)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib', 'vendor']

  spec.test_files = Dir["spec/**/*"]

  spec.add_development_dependency 'bundler', '~> 1.16', '>= 1.16'
  spec.add_development_dependency 'rake', '>= 10.0', '~> 13.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.7', '>= 3.7'
  spec.add_development_dependency 'factory_bot_rails', '~> 4.10.0', '>= 4.10.0'
  spec.add_development_dependency 'action-cable-testing', '~> 0.3.1', '>= 0.3.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.21', '>= 0.8.21'
  spec.add_development_dependency 'pry-rails', '~> 0.3.6', '>= 0.3.6'
  spec.add_development_dependency 'redis', '~> 4.0', '>= 4.0.1'
  spec.add_development_dependency 'rails', '~> 5.2', '>= 5.2.0'
  spec.add_development_dependency 'railties', '~> 5.2', '>= 5.2.0'
end
