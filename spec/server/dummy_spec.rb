require "rspec"
require "rspec_helper"

describe "DUMMY command" do

	before do
		@context = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :credentials=>Credentials.new('designshell')
		)
		@core = DesignShellServer::Core.new(@context)
		#$stdout.sync=true   # no buffer delay
	end

	it "should crack correctly" do
		command = DesignShellServer::Command.new(@core,'DUMMY')
		command.command.should=='DUMMY'
		command.id.should==nil
		command.params.should==nil

		command = DesignShellServer::Command.new(@core,'DUMMY sadf567as756df')
		command.command.should=='DUMMY'
		command.id.should=='sadf567as756df'
		command.params.should==nil

		command = DesignShellServer::Command.new(@core,'DUMMY sadf567as756df {"this": 345345, "that": true}')
		command.command.should=='DUMMY'
		command.id.should=='sadf567as756df'
		command.params.should=={"this"=>345345, "that"=>true}
	end

	it "should call dummy command" do
		command = DesignShellServer::Command.new(@core,'DUMMY','DUMMY')
		command.command.should=='DUMMY'
		command.id.should==nil
		command.params.should==nil
		output = @context.capture_stdout do
			command.execute
		end
		lines = output.split("\n")
		lines[0].should match /^RECEIVED [a-z0-9]+$/
		lines[1].should match /^PROGRESS [a-z0-9]+ \{.*\}$/
		lines[2].should match /^COMPLETE [a-z0-9]+ \{.*\}$/
	end



end