
HighLine::Question.class_eval do
	alias_method :orig_append_default, :append_default
	def append_default
		orig_append_default
		@question = StringUtils.split3(@question,/\|.*\|/) do |head,match,tail|
			match.sub!('|','(')
			match[match.rindex('|'),1]=')'
			match
		end
	end
end


include GLI::App

program_desc 'Describe your application here'

#version DesignShell::VERSION

#desc 'Describe some switch here'
#switch [:s,:switch]

desc 'Set Working Folder'
default_value 'Current folder'
arg_name 'folder'
flag [:f,:folder]

def common_init(global_options,options,args)
	key_chain = DesignShell::KeyChain.new('DesignShell')
	credentials = Credentials.new('DesignShell')
	context = DesignShell::Context.new(
		:global_options=>global_options,
		:options=>options,
		:argv=>args,
		:env=>ENV,
	  :stdout=>$stdout,
	  :stdin=>$stdin,
	  :stderr=>$stderr,
	  :key_chain=>key_chain,
	  :credentials=>credentials
	)
  DesignShell::Core.new(:context=>context)
end

desc 'Deploy from git repository to websites, following deploy plan'
arg_name 'Describe arguments to deploy here'
command :deploy do |cmd|
  cmd.action do |*action_args|
	  ds = common_init(*action_args)
	  ds.deploy
  end
end

desc 'Commit changes to git repository'
arg_name 'You must provide a message'
command :commit do |cmd|
  cmd.action do |*action_args|
	  ds = common_init(*action_args)
	  ds.commit
  end
end

desc 'Commit and push changes to git repository'
arg_name 'You must provide a message'
command :push do |cmd|
  cmd.action do |*action_args|
	  ds = common_init(*action_args)
	  ds.push
  end
end
















#desc 'configure credentials etc'
#arg_name 'subcommands are: bitbucket'
#command :configure do |configure|
#
#	configure.desc 'configure bitbucket for managing repositories'
#	configure.arg_name 'none'
#	configure.command :bitbucket do |bb|
#		bb.action do |global_options,options,args|
#			context = DesignShell::Context.new(
#				:global_options=>global_options,
#				:options=>options,
#				:argv=>args,
#			  :key_chain=>DesignShell::KeyChain.new('DesignShell')
#			)
#			repo = DesignShell::Repo.new
#			core = DesignShell::Core.new(
#				:context => context,
#			  :repo => repo
#			)
#			# use highline to ask questions here and store in key_chain
#			username = ask("User name: ") { |q|
#				q.default = "none"
#			}
#			say username
#		end
#	end
#end
#
#
#desc 'Describe push here'
#arg_name 'Describe arguments to push here'
#command :push do |c|
#  c.desc 'Describe a switch to push'
#  c.switch :s
#
#  c.desc 'Describe a flag to push'
#  c.default_value 'default'
#  c.flag :f
#  c.action do |global_options,options,args|
#
#    # Your command logic here
#
#    # If you have any errors, just raise them
#    # raise "that command made no sense"
#
#    puts "push command ran"
#  end
#end
#
#desc 'Describe pull here'
#arg_name 'Describe arguments to pull here'
#command :pull do |c|
#  c.action do |global_options,options,args|
#    puts "pull command ran"
#  end
#end
#
#
#
#desc 'Describe build here'
#arg_name 'Describe arguments to build here'
#command :build do |c|
#  c.action do |global_options,options,args|
#	  response = POpen4::shell('middleman build')
#	  puts result[:stdout]
#  end
#end


#desc 'List tasks'
#long_desc <<EOS
#List the tasks in your task list, possibly including completed tasks.  By default, this will list
#all uncompleted tasks.
#EOS
#command [:list,:ls] do |c|
#
#	c.desc 'List all tasks, including completed ones'
#	c.command :all do |all|
#		all.action do
#			say 'list all'
#		end
#	end
#
#	c.default_command :all
#end

# download existing repo : ds clone git://somegitrepo
# server side repo clone : ds fork

# ds git ...    # talk directly to git
# ds middleman  # talk directly to middleman


# ds pull git://somegitrepo   # if no local repo, will ask "Do you wish to a) clone somegitrepo into a new folder /asds/dsa/somegitrepo or b) pull changes, except that you aren't inside a repo and haven't specified one"
# ds fork git://somegitrepo


#desc 'Describe clone here'
#arg_name 'Describe arguments to clone here'
#command :clone do |c|
#  c.action do |global_options,options,args|
#    puts "clone command ran"
#  end
#end
#
#pre do |global,command,options,args|
#  # Pre logic here
#  # Return true to proceed; false to abourt and not call the
#  # chosen command
#  # Use skips_pre before a command to skip this block
#  # on that command only
#  true
#end
#
#post do |global,command,options,args|
#  # Post logic here
#  # Use skips_post before a command to skip this
#  # block on that command only
#end
#
#on_error do |exception|
#  # Error logic here
#  # return false to skip default error handling
#  true
#end

