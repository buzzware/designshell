module DesignShell
	class Core

		attr_reader :repo,:configured

		def initialize(aDependencies=nil)
			@@instance = self unless (defined? @@instance) && @@instance
			if aDependencies
				@context = aDependencies[:context]
				@repo = aDependencies[:repo]
				@keyChain = aDependencies[:keyChain]
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
			raise "not configured" if (!configured || !repo || !repo.configured)
			repo.open unless repo.open?
			repo
		end

		def build
			response = POpen4::shell('ls');
			# puts result[:stdout]
		end

	end
end
