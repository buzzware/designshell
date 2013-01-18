require "rspec"
require "rspec_helper"

describe "client to server interaction" do

	before do
		@key_chain = DesignShell::KeyChain.new('DesignShellTest')
		@credentials = Credentials.new('DesignShellTest')
		Dir.chdir @credentials[:deploy_repo_path]
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

	it "should call QUICK and get results" do
		dash = DesignShell::Core.new(
			:context => @context
		)
		result = dash.call_server_command('QUICK')
		puts result
		result.begins_with?('RECEIVED').should == true
		result.index('COMPLETE').should >= 0
	end

	it "should call deploy" do
		dash = DesignShell::Core.new(
			:context => @context
		)
		result = dash.deploy
		puts result
		result.begins_with?('RECEIVED').should == true
		result.index('COMPLETE').should >= 0
	end



	#it "should connect to SSH server" do
	#	Net::SSH.start( @context.credentials[:deploy_host],nil) do |ssh|
	#
	#		#result = ssh.exec!("ls")
	#		#puts result
	#
	#
	#		#ssh.open_channel{|channel| #get root privelages
   #    ##configure behavior of channel
   #    #channel.on_data{|channel, data|
   #    #        puts "#{data}"
   #    #        if data =~ /^Password:/
   #    #           channel.send_data("#{PASSWORD}\n")
   #    #        elsif data =~ /root@/
   #    #            channel.exec("tail /some/log/file.txt")
   #    #            channel.on_data{"STOP LOOPING, DAMN YOU!"}
   #    #        end
   #    #channel.on_close... (etc.)
	#		#
   #    #channel.request_pty do |ch,success|
   #    #        if success
   #    #        puts "pty successfully obtained"
   #    #        else
   #    #        puts "could not obtain pty"
   #    #        end end
	#		#
   #    #channel.exec("sudoshell"){|channel, win| #custom sudo script.
   #    #        if win
   #    #           puts "ss command sent"
   #    #        else puts "ss command FAIL"
   #    #        end
   #    #}
	#		#
	#
	#		ssh.open_channel do |channel|
	#		  channel.on_data do |ch, data|
	#	      puts "got stdout: #{data}"
	#	      #channel.send_data "something for stdin\n"
	#	    end
	#
	#	    channel.on_extended_data do |ch, type, data|
	#	      puts "got stderr: #{data}"
	#	    end
	#
	#	    channel.on_close do |ch|
	#	      puts "channel is closing!"
	#	    end
	#
	#	    channel.request_pty do |ch,success|
   #       if success
   #         puts "pty successfully obtained"
   #       else
   #         puts "could not obtain pty"
   #       end
	#	    end
	#		  #sleep 1
	#		  result = channel.exec("DEPLOY") do |ch, success|
	#		    abort "could not execute command" unless success
	#		  end
	#		  channel.wait
	#			puts result
	#		end
	#
	#		ssh.loop
	#
	#	end
	#end

end