lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fie/version'

Gem::Specification.new do |spec|
  spec.name          = 'fie'
  spec.version       = Fie::VERSION
  spec.authors       = ['Eran Peer']
  spec.email         = ['eran.peer79@gmail.com']

  spec.summary       = %q{Fie is a Rails-centric frontend framework running over a permanent WebSocket connection.}
  spec.metadata    = { "source_code_uri" => "https://github.com/raen79/fie" }
  spec.homepage      = 'https://fie.eranpeer.co'
  spec.license       = 'MIT'

  spec.files = 
    Dir['lib/*.rb'] +
    Dir['lib/fie/*.rb'] +
    Dir['lib/fie/state/*.rb'] +
    Dir['lib/fie/layouts/*.html.erb'] +
    Dir['vendor/javascript/fie.js']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib', 'vendor']

  spec.add_development_dependency 'bundler', '~> 1.16', '>= 1.16'
  spec.add_development_dependency 'rake', '~> 10.0', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0', '>= 3.0'
  spec.add_development_dependency 'opal', '~> 0.11.0', '>= 0.11.0'
  spec.add_development_dependency 'guard-rake', '~> 1.0.0', '>= 1.0.0'
  spec.add_runtime_dependency 'redis', '~> 4.0', '>= 4.0.1'
  spec.add_runtime_dependency 'rails', '~> 5.2', '>= 5.2.0'
  spec.add_runtime_dependency 'railties', '~> 5.2', '>= 5.2.0'
end
