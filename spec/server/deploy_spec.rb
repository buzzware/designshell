require "rspec"
require "rspec_helper"

describe "DEPLOY command" do

	before do

		key_chain = DesignShell::KeyChain.new('DesignShellTest')
		#key_chain.set('site_user',creds[:site_user])
		#key_chain.set('site_password',creds[:site_password])

		@context = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :key_chain=>key_chain,
		  :credentials=>Credentials.new('designshell')
		)
		#$stdout.sync=true   # no buffer delay
	end

	it "should prepare_cache not pre-existing" do
		core = DesignShellServer::Core.new(@context)
		site = "happy.com.au"
		repo_url = "git@github.com:buzzware/underscore_plus.git"
		wd = core.working_dir_from_site(site)
		FileUtils.rm_rf wd
		command = DesignShellServer::Command.new(core,"DEPLOY "+JSON.generate({:repo_url=>repo_url,:site=>site}))
		command.prepare_cache
		repo = DesignShell::Repo.new
		repo.open wd
		repo.origin.url==repo_url
	end

	it "should prepare_cache pre-existing, to given commit" do
		core = DesignShellServer::Core.new(@context)
		site = "happy.com.au"
		repo_url = "git@github.com:buzzware/underscore_plus.git"
		wd = core.working_dir_from_site(site)
		commit1 = '4b133ff8825bbd488ba61fa3e3b82a5fa746ac6a'
		FileUtils.rm_rf wd
		command = DesignShellServer::Command.new(core,"DEPLOY "+JSON.generate({
			:repo_url=>repo_url,
			:site=>site,
		  :commit=>commit1
		}))
		command.prepare_cache
		head_commit = command.repo.head.to_s
		head_commit.should_not==commit1
		command.checkout_branch_commit
		command.repo.head.to_s.should==commit1

		# now try checkout_branch_commit with no specified branch or commit - should checkout head
		command = DesignShellServer::Command.new(core,"DEPLOY "+JSON.generate({
			:repo_url=>repo_url,
			:site=>site
		}))
		command.repo = DesignShell::Repo.new
		command.repo.open wd
		command.checkout_branch_commit
		command.repo.head.to_s.should==head_commit
	end

end