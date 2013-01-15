require "rspec"
require "rspec_helper"
require 'securerandom'

describe "SiteClient" do

	before do
		creds = Credentials.new('designshell')
		key_chain = DesignShell::KeyChain.new('DesignShellTest')
		#key_chain.set('site_user',creds[:site_user])
		#key_chain.set('site_password',creds[:site_password])

		@context = DesignShell::Context.new(:key_chain=>key_chain, :credentials=>creds)
		@client = DesignShell::SiteClient.new({
			:site_url => creds[:bigcommerce_sandbox_url],
			:site_username => creds[:bigcommerce_sandbox_username],
			:site_password => creds[:bigcommerce_sandbox_password]
		})
	end

	it "should connect and list" do
		result = @client.ls
		result.include?('content/').should==true
		result.include?('template/').should==true
		result = @client.ls('/')
		result.include?('content/').should==true
		result.include?('template/').should==true
		result = @client.ls('template')
		result.include?('Panels/').should==true
		result.include?('Snippets/').should==true
	end

	it "should put a string to a file, then get and check" do
		content = StringUtils.random_word(8,8)
		path = '/content/testfile.txt'
		@client.put_string(path,content)
		content2 = @client.get_string(path)
		content2.should == content
		@client.delete(path)
	end

	it "should delete files" do
		content = StringUtils.random_word(8,8)
		path = '/content/testfile.txt'

		@client.put_string(path,content)
		@client.get_string(path).should == content
		@client.delete(path)
		@client.get_string(path).should==nil
		@client.delete(path)  # shouldn't blow up
	end

	it "should read and write the deploy_status" do
		@client.deploy_status_file = '/content/.fake_deploy_status.txt'

		@client.delete @client.deploy_status_file
		@client.deploy_status == {}
		content1 = {"commit" => "deadbeef"}
		@client.deploy_status = content1
		@client.deploy_status.should == content1
		@client.delete @client.deploy_status_file
	end

	it "should upload and download a file and check" do
		content = SecureRandom.random_bytes(8000)
		tempfile = MiscUtils.make_temp_file(nil,nil,content)
		remote_path = '/content/testfile.bin'
		@client.put_file(tempfile,remote_path)
		tempfile2 = MiscUtils.temp_file
		@client.get_file(remote_path,tempfile2)
		`cmp #{tempfile} #{tempfile2}`.should==''
		@client.delete remote_path
	end

	it "should put file even when folder doesn't exist" do
		content = StringUtils.random_word(8,8)
		path = '/content/some/testfile.txt'
		@client.delete('/content/some')
		@client.exists?('/content/some').should==false
		@client.get_string(path).should==nil
		@client.ensure_folder_path(File.dirname(path))
		@client.put_string(path,content)
		content2 = @client.get_string(path)
		content2.should == content
		@client.delete('/content/some')
		@client.exists?('/content/some').should==false
		@client.exists?(path).should==false
	end

end