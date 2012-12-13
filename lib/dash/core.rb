module Dash
	class Core

		attr_reader :repo,:configured

		def initialize(aContext)
			@@instance = self unless @@instance
			@repo = Repo.new(self)
			configure(aContext) if aContext
		end

		def self.instance
			return @@instance || @@instance=Dash::Repo.new
		end

		def configure(aContext)
			@repo.configure(aContext)
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
