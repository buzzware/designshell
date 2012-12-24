module DesignShell

	class Context
		attr_reader :global_options,:options,:arguments,:pwd
		def initialize(*args)
			@global_options,@options,@arguments = args
			@pwd = Dir.pwd
		end
	end

end
