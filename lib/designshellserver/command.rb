module DesignShellServer
	class Command

		attr_reader :core,:context,:line,:command,:id,:params

		def initialize(aCore,aLine,aCommandName=nil)
			@core = aCore
			@context = aCore.context
			@line = aLine
			tl = aLine.clone
			cmd = tl.extract!(/^[A-Z0-9_]+/)
			@command = aCommandName || cmd
			tl.bite! ' '
			@id = tl.extract!(/[a-z0-9]+/)
			tl.bite! ' '
			@params = ::JSON.parse(tl) if @params = tl.to_nil
		end

		def execute
			self.send @command.to_sym
		end

		def writeline(aString)
			@context.stdout.puts aString
		end

		def prepare_cache(aParams) # {:url=>'git://github.com/ddssda', :branch=>'master', :commit=>'ad452bcd'}

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
			deploy
		end

	end
end