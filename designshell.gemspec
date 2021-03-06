# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','designshell','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'designshell'
  s.version = DesignShell::VERSION
  s.author = 'Gary McGhee'
  s.email = 'contact@buzzware.com.au'
  s.summary = 'DesignShell is the shell for designers'
  s.description   = 'All-round workflow tool for designers. Enables designers to comfortably use geek goodness like git, git deploy, SASS etc'
  s.require_paths = ["lib"]
  s.homepage = 'http://github.com/buzzware/designshell'
  s.platform = Gem::Platform::RUBY
# Add your other files here if you make them
  #s.files         = `git ls-files`.split($\)
	ignores = File.readlines(".gitignore").grep(/\S+/).map {|line| line.chomp }
	dotfiles = [".gitignore"]
	s.files = Dir["**/*"].reject {|f| File.directory?(f) || ignores.any? {|i| File.fnmatch(i, f) } } + dotfiles
	#sss = ['Gemfile']
	#s.files = sss
  s.bindir = 'bin'
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
	#s.test_files = s.files.grep(/^spec\//)
  #s.has_rdoc = true
  #s.extra_rdoc_files = ['README.rdoc','designshell.rdoc']
  #s.rdoc_options << '--title' << 'designshell' << '--main' << 'README.rdoc' << '-ri'
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
	s.add_runtime_dependency('net_dav')
	s.add_runtime_dependency('net-ssh')

end
