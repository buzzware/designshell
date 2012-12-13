module Dash
	class Repo

		attr_reader :git,:configured

		def initialize(aDash)
			@dash = aDash
		end

		def configure(aContext)
			# set @path
			@configured = true
		end

		def open
			@git = Git.open(@path, :log => Logger.new(STDOUT))
		end

		def open?
			!!@git
		end

		def commit
			repo.git.commit_all()
		end

	end
end