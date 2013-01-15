module DesignShellServer
	class Command

		attr_accessor :core,:context,:line,:command,:id,:params,:repo

		def initialize(aCore,aLine,aCommandName=nil)
			@core = aCore
			@context = aCore && aCore.context
			@line = aLine
			tl = aLine.dup
			cmd = tl.extract!(/^[A-Z0-9_]+/)
			@command = aCommandName || cmd
			tl.bite! ' '
			@id = tl.extract!(/^[a-z0-9]+/)
			tl.bite! ' '
			@params = ::JSON.parse(tl) if @params = tl.to_nil
		end

		def execute
			self.send @command.to_sym
		end

		def writeline(aString)
			@context.stdout.puts aString
		end

		# Prepares repo in cache dir for site
		# requires params: repo_url,site
		def prepare_cache # {:url=>'git://github.com/ddssda', :branch=>'master', :commit=>'ad452bcd'}
			url = @params['repo_url']
			site = @params['site']
			wd = @core.working_dir_from_site(site)

			@repo = DesignShell::Repo.new
			suitable = if File.exists?(wd)
				@repo.open wd
				@repo.origin.url==url
			else
				false
			end

			if suitable
				@repo.fetch
			else
				if File.exists? wd
					raise RuntimeError.new('almost did bad delete') if !@core.cache_dir || @core.cache_dir.length<3 || !wd.begins_with?(@core.cache_dir)
					FileUtils.rm_rf wd
				end
				@repo.clone(url, wd)
			end
		end

		# Switches @repo to given branch and/or commit
		# Should call prepare_cache first to create @repo
		# requires params: branch and/or commit
		def checkout_branch_commit
			#url = @params['repo_url']
			#site = @params['site']
			#wd = @core.working_dir_from_site(site)
			branch = @params['branch'] || 'master'
			commit = @params['commit']
			@repo.checkout(commit,branch)
			#perhaps use reset --hard here
			if (commit)
				@repo.merge(commit,['--ff-only'])
			else
				@repo.merge('origin/'+branch,['--ff-only'])
			end
		end

		# Determines whether to do an incremental or complete deploy and deploys current files in repo working dir to repo_url
		# requires :
		#   uses: site_client.deploy_status
		#   params: deploy_cred
		def deploy
			deployPlanString = @repo.get_file_content('.deploy_plan.xml',@params['commit']||@params['branch'])
			xmlRoot = XmlUtils.get_xml_root(deployPlanString)
			# select plan
			planNode = XmlUtils.single_node(xmlRoot,'plan')
			# for each deploy
			deployNode = XmlUtils.single_node(planNode,'deploy')
			# create client for kind/method
			@site_client = DesignShell::SiteClient.new({
				:site_url => @params['site_url'],
				:site_username => @params['site_username'],
				:site_password => @params['site_password'],
			})
			ds = @site_client.deploy_status
			site_repo_url = ds && ds['repo_url'].to_nil
			site_branch = ds && ds['branch'].to_nil
			site_commit = ds && ds['commit'].to_nil
			repo_url = @repo.url
			# @todo must limit uploads to build folder
			fromPath = MiscUtils.ensure_slashes(XmlUtils.peek_node_value(deployNode,'fromPath','/'),false,true)    # eg. /build/bigcommerce effectively selects a subfolder that should be debased
			toPath = MiscUtils.ensure_slashes(XmlUtils.peek_node_value(deployNode,'toPath','/'),false,true)    # eg. / effectively the new base for these files
			if site_repo_url && site_repo_url==repo_url && site_branch && site_commit
				# incremental
				changes = @repo.changesBetweenCommits(site_commit,@repo.head.to_s)
				uploads,deletes = convertChangesToUploadsDeletes(changes)
				uploads.delete_if { |fp| !fp.begins_with?(fromPath) }
				deletes.delete_if { |fp| !fp.begins_with?(fromPath) }
				@site_client.delete_files(deletes,fromPath,toPath)
				@site_client.upload_files(@repo.path,uploads,fromPath,toPath)
				@site_client.deploy_status = {
					:repo_url => @repo.url,
					:branch => @repo.branch,
					:commit => @repo.head.to_s,
				  :fromPath => fromPath,
				  :toPath => toPath
				}
			else
				# complete
				# for now, just deploy all files in wd, creating folders as necessary
				# later, delete remote files not in wd except for eg. .deploy-status.xml and perhaps upload folders
				uploads = MiscUtils.recursive_file_list(@repo.path,false)
				uploads.delete_if do |fp|
					!fp.begins_with?(fromPath) || fp.begins_with?('.git/')
				end
				@site_client.upload_files(@repo.path,uploads,fromPath,toPath)
				@site_client.deploy_status = {
					:repo_url => @repo.url,
					:branch => @repo.branch,
					:commit => @repo.head.to_s,
					:fromPath => fromPath,
		      :toPath => toPath
				}
			end
		end

		# Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R), have their type (i.e. regular file, symlink, submodule, ...) changed (T)
		def convertChangesToUploadsDeletes(changes)
			uploads = []
			deletes = []
			changes.each do |line|
				continue if line==""
				tabi = line.index("\t")
				status = line[0,tabi]
				path = line[tabi+1..-1]
				if status.index('D')
					deletes << path
				else
					uploads << path
				end
			end
			return uploads,deletes
		end

		def DUMMY
			id = StringUtils.random_word(8,8)
			writeline "RECEIVED "+id
			sleep 1
			detail = ::JSON.generate({:this=>5, :that=>'ABC'}) #JSON.parse(document) or JSON.generate(data)
			writeline ['PROGRESS',id,detail].join(' ')
			sleep 1
			detail = ::JSON.generate({:result=>123}) #JSON.parse(document) or JSON.generate(data)
			writeline ['COMPLETE',id,detail].join(' ')
		end

		def QUICK
			id = StringUtils.random_word(8,8)
			writeline "RECEIVED "+id
			writeline "COMPLETE "+id
		end

		def DEPLOY # {}
			prepare_cache
			checkout_branch_commit
			deploy
		end


	end
end