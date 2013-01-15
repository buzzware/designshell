require "rspec"
require "rspec_helper"

describe "client to server interaction" do

	before do
		@key_chain = DesignShell::KeyChain.new('DesignShellTest')
		@credentials = Credentials.new('designshell')
		@context = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :key_chain=>@key_chain,
		  :credentials=>@credentials
		)
	end

	it "should call DUMMY and get results" do
		dash = DesignShell::Core.new(
			:context => @context
		  #:repo => repo
		)
		result = dash.call_server_command('DEPLOY')
		result.should == "DUMMY"
	end

end