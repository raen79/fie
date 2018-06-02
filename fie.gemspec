lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fie/version'

Gem::Specification.new do |spec|
  spec.name          = 'fie'
  spec.version       = Fie::VERSION
  spec.authors       = ['Eran Peer']
  spec.email         = ['eran.peer79@gmail.com']

  spec.summary       = %q{Fie is a Rails-centric frontend framework running over a permanent WebSocket connection.}
  spec.homepage      = 'http://fie.eranpeer.co'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'Set to \'http://mygemserver.com\''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = ['spec', 'lib']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'opal'
  spec.add_development_dependency 'guard-rake'
  spec.add_dependency 'redis', '~> 4.0.1'
  spec.add_dependency 'rails'
  spec.add_dependency 'railties'
end
