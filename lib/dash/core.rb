module Dash
	class Core

		attr_reader :repo,:configured

		def initialize(aDependencies)
			@@instance = self unless (defined? @@instance) && @@instance
			@context = aDependencies[:context]
			@repo = aDependencies[:repo]
			@keyChain = aDependencies[:keyChain]
			configure(@context) if @context
		end

		def self.instance
			(defined? @@instance) && @@instance
		end

		def configure(aContext)
			@configured = true
		end

		def ensure_repo_open
			raise Error.new('not configured') if !configured? || !repo || !repo.configured?
			repo.open unless repo.open?
			repo
		end

		def build
			response = POpen4::shell('somebinary');
			# puts result[:stdout]
		end

	end
end
