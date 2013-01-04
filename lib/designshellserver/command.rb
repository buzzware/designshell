module DesignShellServer
	class Command

		attr_accessor :core,:context,:line,:command,:id,:params,:repo

		def initialize(aCore,aLine,aCommandName=nil)
			@core = aCore
			@context = aCore.context
			@line = aLine
			tl = aLine.clone
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

		# should call prepare_cache first to create @repo
		def checkout_branch_commit
			url = @params['repo_url']
			site = @params['site']
			wd = @core.working_dir_from_site(site)
			branch = @params['branch']
			commit = @params['commit']
			@repo.checkout(commit,branch)
		end

		def deploy

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


		def DEPLOY # {}
			prepare_cache
			checkout_branch_commit
			deploy
		end

	end
end