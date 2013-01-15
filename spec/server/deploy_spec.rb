require "rspec"
require "rspec_helper"

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

describe "DEPLOY command" do

	before do

		@key_chain = DesignShell::KeyChain.new('DesignShellTest')
		@credentials = Credentials.new('designshell')
		#key_chain.set('site_user',creds[:site_user])
		#key_chain.set('site_password',creds[:site_password])

		@context = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :key_chain=>@key_chain,
		  :credentials=>@credentials
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

	it "should put file when folder doesn't exist" do
		site_client = DesignShell::SiteClient.new({
			:site_url => @context.credentials[:bigcommerce_sandbox_url],
			:site_username => @context.credentials[:bigcommerce_sandbox_username],
			:site_password => @context.credentials[:bigcommerce_sandbox_password]
		})
		site_client.delete '/content/deploy_spec'
		site_client.deploy_status = nil

		content1 = StringUtils.random_word(8,8)
		source = MiscUtils.make_temp_file(nil,nil,content1)
		dest = "/content/deploy_spec/content/content1.txt"
		site_client.put_file(source,dest)

		content2 = site_client.get_string(dest)
		content2.should == content1
	end


	it "should deploy, no existing cache" do

		# set up scratch repo with basic site
		@context.pwd = MiscUtils.append_slash(MiscUtils.real_path(MiscUtils.make_temp_dir('deploy_spec')))
		Dir.chdir @context.pwd

		repo = DesignShell::Repo.new
		repo.clone @context.credentials[:scratch_repo_url],@context.pwd
		files_to_rm = Dir.glob(@context.pwd+'*').filter_exclude(@context.pwd+'.git')
		if !files_to_rm.empty?
			files_to_rm.each {|fp| FileUtils.rm_rf fp}
			repo.commit_all "cleared"
		end
		FileUtils.mkdir_p 'build'
		FileUtils.mkdir_p 'build/bigcommerce'  
		FileUtils.mkdir_p 'build/bigcommerce/template'  
		MiscUtils.string_to_file "<html><body>a bigcommerce template</body></html>",'build/bigcommerce/template/template.html'
		FileUtils.mkdir_p 'build/bigcommerce/content'  
		MiscUtils.string_to_file "first content file",'build/bigcommerce/content/content1.txt'
		MiscUtils.string_to_file "second content file",'build/bigcommerce/content/content2.txt'
		FileUtils.mkdir_p 'build/tumblr'
		MiscUtils.string_to_file "<html><body>a tumblr template</body></html>",'build/tumblr/template.html'

deploy_plan = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<deployPlan site="testmart.com">
	<plan name="main">
		<deploy>
			<kind>BigCommerce</kind>
			<method>WebDav</method>
			<fromPath>/build/bigcommerce</fromPath>
			<toPath>/content/deploy_spec</toPath>
			<item name="site_url">#{@context.credentials[:bigcommerce_sandbox_url]}</item> <!-- get this from user creds -->
			<item name="site_username" key="site_user"/>
			<item name="site_password" key="site_password"/>
		</deploy>
	</plan>
</deployPlan>
EOS
		MiscUtils.string_to_file deploy_plan,'.deploy_plan.xml'
		FileUtils.cp_r 'build','source'
		repo.add '.'
		repo.commit_all "first test files"
		repo.push

		# clear deploy destination
		site_client = DesignShell::SiteClient.new({
			:site_url => @context.credentials[:bigcommerce_sandbox_url],
			:site_username => @context.credentials[:bigcommerce_sandbox_username],
			:site_password => @context.credentials[:bigcommerce_sandbox_password]
		})
		site_client.delete '/content/deploy_spec'
		site_client.deploy_status = nil

		# setup client to deploy
		dash = DesignShell::Core.new(
			:context => @context,
		  :repo => repo
		)

		# stub out call_server_command and get line
		line_for_server = nil
		params_for_server = nil
		dash.stub!(:call_server_command) do |aCommand, aParams|
			line_for_server = aCommand
			params_for_server = aParams
			line_for_server += " " + JSON.generate(aParams) if aParams
		end
		dash.deploy

		# server receives line from client
		serverContext = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :key_chain=>@key_chain,
		  :credentials=>@credentials
		)
		server = DesignShellServer::Core.new(serverContext)
		FileUtils.rm_rf server.working_dir_from_site(params_for_server['site']) if params_for_server['site']
		command = server.make_command(line_for_server)
		command.execute

		# check deployed files
		deployed_files = site_client.list_files('/content/deploy_spec',true)
		deployed_files.sort.should==[
			"content/content1.txt",
			"content/content2.txt",
			"template/template.html"
		]
		site_client.deploy_status.should == {
			'repo_url' => repo.url,
			'branch' => repo.branch,
			'commit' => repo.head.to_s,
		  'fromPath' => 'build/bigcommerce/',
		  'toPath' => 'content/deploy_spec/'
		}

		MiscUtils.string_to_file "third content file",'build/bigcommerce/content/content3.txt'
		FileUtils.rm 'build/bigcommerce/content/content2.txt'
		repo.add '.'
		repo.commit_all "added content3, removed content2"
		repo.push

		command = server.make_command(line_for_server)
		command.execute

		# check deployed changes
		deployed_files = site_client.list_files('/content/deploy_spec',true).sort
		deployed_files.should==[
			"content/content1.txt",
			"content/content3.txt",
			"template/template.html"
		]

	end

end