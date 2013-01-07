module DesignShell
	class Core

		attr_reader :repo,:configured

		def initialize(aDependencies=nil)
			@@instance = self unless (defined? @@instance) && @@instance
			if aDependencies
				@context = aDependencies[:context]
				@repo = aDependencies[:repo]
				@keyChain = aDependencies[:keyChain]
			end
			configure(@context) if @context
		end

		def self.instance
			(defined? @@instance) && @@instance
		end

		def configure(aContext)
			@configured = true
		end

		def ensure_repo_open
			raise "not configured" if (!configured || !repo || !repo.configured)
			repo.open unless repo.open?
			repo
		end

		def build
			response = POpen4::shell('ls');
			# puts result[:stdout]
		end


		def deploy
			ensure_repo_open
			deploy_branch = 'master'

			deployPlanString = repo.get_file_content('deploy_plan.xml',deploy_branch)
			xmlRoot = XmlUtils.get_xml_root(deployPlanString)
			planNode = XmlUtils.single_node(xmlRoot,'plan')
			deployNode = XmlUtils.single_node(xmlRoot,'deploy')
			deploy_cred = {}
			REXML::XPath.each(deployNode,'credential') do |n|
				next unless n['name']
				if text = n.text.to_nil             # value in node
					deploy_cred[n['name']] = n.text
				else                                # value in @params['deploy_creds']
					key = n['key'] || n['name']
					deploy_cred[n['name']] = @keyChain[key]
				end
			end
			# call server with DEPLOY {"deploy_cred": deploy_cred}
			Net::SSH.start(@context.credentials[:deploy_server], @keyChain[:deploy_user]) do |ssh|
			  result = ssh.exec!("ls -l")
			  puts result
			end
			#keys = "/home/user/ssh/ssh_key"
			#Net::SSH.start(ssh_host, ssh_option["ssh_username"], :port => ssh_option["ssh_port"], \
			# :password => ssh_option["ssh_password"], :keys => keys) do |ssh|
			#  #your ssh code
			#end

			#http://stackoverflow.com/questions/6905934/using-ruby-and-net-ssh-how-do-i-authenticate-using-the-key-data-parameter-with
			#HOST = '172.20.0.31'
			#USER = 'root'
			#
			#KEYS = [ "-----BEGIN RSA PRIVATE KEY-----
			#MIIEogIBAAKCAQEAqccvUza8FCinI4X8HSiXwIqQN6TGvcNBJnjPqGJxlstq1IfU
			#kFa3S9eJl+CBkyjfvJ5ggdLN0S2EuGWwc/bdE3LKOWX8F15tFP0=
			#-----END RSA PRIVATE KEY-----" ]
			#
			#Net::SSH.start( HOST, USER, :key_data => KEYS, :keys_only => TRUE) do|ssh|
			#result = ssh.exec!('ls')
			#puts result
			#end


		end

	end
end
