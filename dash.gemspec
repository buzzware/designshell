# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','dash','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'dash'
  s.version = Dash::VERSION
  s.author = 'Gary McGhee'
  s.email = 'your@email.address.com'
  s.homepage = 'http://github.com/buzzware/dash'
  s.platform = Gem::Platform::RUBY
  s.summary = 'DaSH is the Design Shell'
# Add your other files here if you make them
  s.files = %w(
bin/dash
lib/dash/version.rb
lib/dash.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','dash.rdoc']
  s.rdoc_options << '--title' << 'dash' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'dash'
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-core')
  s.add_development_dependency('rdoc')
	s.add_development_dependency('aruba')
	s.add_development_dependency('ruby-debug')
  s.add_runtime_dependency('gli','2.5.0')
	s.add_runtime_dependency('termios')
	s.add_runtime_dependency('highline')
	s.add_runtime_dependency('git')
	s.add_runtime_dependency('middleman')
	s.add_runtime_dependency('buzzcore')
	s.add_runtime_dependency('POpen4')
	s.add_runtime_dependency('bitbucket_rest_api')
	s.add_runtime_dependency('osx_keychain')

end
