module DesignShell
	class Core

		attr_reader :repo,:configured,:context

		def initialize(aDependencies=nil)
			@@instance = self unless (defined? @@instance) && @@instance
			if aDependencies
				@context = aDependencies[:context]
				@repo = aDependencies[:repo]
				@keyChain = aDependencies[:keyChain] || @context.key_chain
			end
			configure(@context) if @context
		end

		def self.instance
			(defined? @@instance) && @@instance
		end

		def configure(aContext=@context)
			@configured = true
		end

		def ensure_repo_open
			if (!@repo && @context)
				if @context.git_root
					@repo = DesignShell::Repo.new
					@repo.open @context.git_root
				end
			end
			raise "unable to open repository" unless @repo.open?
			@repo
		end

		def ensure_deploy_server
			@conn ||= Net::SSH.start(@context.credentials[:deploy_host],nil)
		end

		def deploy_plan(*args)
			return @deploy_plan if args.empty?
			plan = args.first
			if plan.is_a?(DesignShell::DeployPlan)
				@deploy_plan = plan
			elsif plan
				@deploy_plan = DesignShell::DeployPlan.new(:core => self,:plan => plan)
			end
			@deploy_plan
		end

		def call_server_command(aCommand, aParams=nil)
			#ds_conn = ensure_deploy_server
			command = aCommand
			command += " " + ::JSON.generate(aParams) if aParams
			#result = ds_conn.exec!(command)
			result = nil
			Net::SSH.start(@context.credentials[:deploy_host],nil) do |ssh|
				result = ssh.exec!(command)
			end
			result
		end

		def build
			response = POpen4::shell('ls')
			# puts result[:stdout]
		end

		def commit
			ensure_repo_open
			msg = @context.argv[0]
			if !msg.to_nil
				msg = ask("Please provide a comment eg. what this change is about : ") #{ |q| q.default = "none" }
			end
			exit_now!('Cannot commit without a comment') unless msg.to_nil
			repo.commit_all(msg)
		end

		def push
			commit if repo.changes?
			repo.push
		end

		def deploy
			ensure_repo_open
			deploy_branch = 'master'
			deploy_plan(repo.get_file_content('.deploy_plan.xml',deploy_branch))
			params = deploy_plan.deploy_items_values.clone
			params['site'] = deploy_plan.site
			params['repo_url'] = repo.origin.url
			puts call_server_command('DEPLOY',params)
		end


	end
end
