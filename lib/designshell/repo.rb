module DesignShell
	class Repo

		attr_reader :git,:configured

		GIT_METHODS = [:commit,:add,:reset_hard,:path,:clone,:log,:size,:branches,:status]

		def initialize(aDesignShell=nil)
			@ds = aDesignShell
		end

		def method_missing(sym, *args, &block)
			if @git && GIT_METHODS.include?(sym)
				@git.send sym, *args, &block
			else
				super
			end
		end

		def configure(aContext=nil)
			# set @path
			@configured = true
		end

		def open(aPath)
			@git = Git.open(aPath, :log => Logger.new(STDOUT))
		end

		def init(*args)
			@git = Git.init(*args)
		end

		def clone(aUrl,aPath)
			@git = Git::clone(aUrl,aPath)
		end

		def open?
			!!@git
		end

		def empty?
			!@git.branches[0]
		end

		def commit_all(*args)
			result = begin
				@git.commit_all(*args)
			rescue Git::GitExecuteError => e
				if e.message.index("nothing to commit (working directory clean)") >= 0
					nil
				else
					raise e
				end
			end
			result = commitFromString(result)
			result
		end

		# "[master (root-commit) 6bdd9e1] first commit  1 files changed, 1 insertions(+), 0 deletions(-)  create mode 100644 file1.txt"
		def commitFromString(aString)
			return nil if !aString || aString.empty?
			sha = aString.scan(/ ([a-f0-9]+)\]/).flatten.first
			@git.gcommit(sha)
		end

		def path
			@git.dir.path
		end
	end
end