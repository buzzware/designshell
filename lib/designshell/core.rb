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

		def configure(aContext)
			@configured = true
		end

		def ensure_repo_open
			raise "not configured" if (!repo && !repo.configured && !@configured)
			repo.open unless repo.open?
			repo
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

		def build
			response = POpen4::shell('ls')
			# puts result[:stdout]
		end

		def deploy
			ensure_repo_open
			deploy_branch = 'master'
			deploy_plan(repo.get_file_content('.deploy_plan.xml',deploy_branch))
			params = deploy_plan.deploy_items_values.clone
			params['site'] = deploy_plan.site
			params['repo_url'] = repo.origin.url
			context.stdout.puts call_server_command('DEPLOY',params)
		end

		def call_server_command(aCommand, aParams)
			result = nil
			Net::SSH.start(@context.credentials[:deploy_host]) do |ssh|
				command = aCommand
				command += " " + JSON.generate(aParams) if aParams
				result = ssh.exec!(command)
			end
			result
		end

	end
end
