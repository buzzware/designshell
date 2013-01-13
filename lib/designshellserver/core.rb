module DesignShellServer
	class Core

		attr_reader :context

		def initialize(aContext)
			@context = aContext
		end

		def make_command(aLine)
			command_name = aLine.scan(/^[A-Z0-9_]+/).pop.to_nil
			return nil unless command_name && DesignShellServer::Command.instance_methods.include?(command_name)
			return DesignShellServer::Command.new(self,aLine,command_name)
		end

		def run
			@context.stdout.print "\n>"

			@context.stdin.each_line do |line| line.chomp! "\n"

				command = make_command(line)
				command.execute

			@context.stdout.print "\n>"
			end
		end

		def cache_dir
			@cache_dir ||= MiscUtils.append_slash(@context.credentials[:cache_dir] || MiscUtils.make_temp_dir('DesignShellServer'))
		end

		def working_dir_from_site(aSite)
			return nil unless aSite
			aSite.gsub!(/[^a-zA-Z0-9.\-_]/,'_')
			File.join(cache_dir,aSite)
		end

	end
end
