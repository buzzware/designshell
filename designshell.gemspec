# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','designshell','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'designshell'
  s.version = DesignShell::VERSION
  s.author = 'Gary McGhee'
  s.email = 'contact@buzzware.com.au'
  s.homepage = 'http://github.com/buzzware/designshell'
  s.platform = Gem::Platform::RUBY
  s.summary = 'DesignShell is the shell for designers'
# Add your other files here if you make them
  s.files = %w(
bin/designshell
lib/designshell/version.rb
lib/designshell.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','designshell.rdoc']
  s.rdoc_options << '--title' << 'designshell' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
	s.executables << 'ds'
	s.executables << 'designshelld.rb'
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
	s.add_runtime_dependency('json')

end
