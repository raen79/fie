lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fie/version'

Gem::Specification.new do |spec|
  spec.name          = 'fie'
  spec.version       = Fie::VERSION
  spec.authors       = ['Eran Peer']
  spec.email         = ['eran.peer79@gmail.com']

  spec.summary       = %q{Fie is a Rails-centric frontend framework running over a permanent WebSocket connection.}
  spec.description   = %q{
    fie is a framework for Ruby on Rails that shares the state of your views with the backend.
    For each controller within which you wish to use fie, you must create a commander. fie uses commanders in the same way a Ruby on Rails application uses controllers.
    When an instance variable is changed in the commander, the view is updated. Likewise, if the same variable is modified within the view (through a form for example), the change is reflected in the commander and within other instances of the variable in the view. This means that fie supports three-way data binding.
    fie therefore replaces traditional Javascript frontend frameworks, while requiring you to write less code overall. If you implement fie within your application, you will no longer rely on Javascript for complex tasks, but rather use it only for what it was intended to be used for: to be sprinkled in your views and make them feel more dynamic (through animations for example).
  }
  spec.metadata    = { "source_code_uri" => "https://github.com/raen79/fie" }
  spec.homepage      = 'https://fie.eranpeer.co'
  spec.license       = 'MIT'

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
  spec.add_dependency 'rails', '>= 5.2.0'
  spec.add_dependency 'railties'
end
