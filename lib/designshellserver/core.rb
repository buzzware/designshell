module DesignShellServer
	class Core

		attr_reader :context

		def initialize(aContext)
			@context = aContext
		end

		def make_command(aContext,aLine)
			command_name = aLine.scan(/^[A-Z0-9_]+/).pop.to_nil
			return nil unless command_name && DesignShellServer::Command.instance_methods.include?(command_name)
			return DesignShellServer::Command.new(aContext,aLine,command_name)
		end

		def run
			@context.stdout.print "\n>"

			@context.stdin.each_line do |line| line.chomp! "\n"

				command = make_command(context,line)
				command.execute

			@context.stdout.print "\n>"
			end
		end

	end
end
