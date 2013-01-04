require "rspec"
require "rspec_helper"
require 'securerandom'

describe "SiteClient" do

	it "should connect and list" do
		@context = DesignShell::Context.new(:credentials=>Credentials.new('designshell'))
		@client = DesignShell::SiteClient.new(@context)
		result = @client.ls('.')
		result.include?('/content/').should==true
		result.include?('/template/').should==true
	end

	it "should put a string to a file, then get and check" do
		@context = DesignShell::Context.new(:credentials=>Credentials.new('designshell'))
		@client = DesignShell::SiteClient.new(@context)
		content = StringUtils.random_word(8,8)
		path = '/content/testfile.txt'
		@client.put_string(path,content)
		content2 = @client.get_string(path)
		content2.should == content
		@client.delete(path)
	end

	it "should delete files" do
		@context = DesignShell::Context.new(:credentials=>Credentials.new('designshell'))
		@client = DesignShell::SiteClient.new(@context)
		content = StringUtils.random_word(8,8)
		path = '/content/testfile.txt'

		@client.put_string(path,content)
		@client.get_string(path).should == content
		@client.delete(path)
		@client.get_string(path).should==nil
		@client.delete(path)  # shouldn't blow up
	end

	it "should read and write the deploy_status" do
		@context = DesignShell::Context.new(:credentials=>Credentials.new('designshell'))
		@client = DesignShell::SiteClient.new(@context)
		@client.deploy_status_file = '/content/.fake_deploy_status.txt'

		@client.delete @client.deploy_status_file
		@client.deploy_status == {}
		content1 = {"commit" => "deadbeef"}
		@client.deploy_status = content1
		@client.deploy_status.should == content1
		@client.delete @client.deploy_status_file
	end

	it "should upload and download a file and check" do
		@context = DesignShell::Context.new(:credentials=>Credentials.new('designshell'))
		@client = DesignShell::SiteClient.new(@context)

		content = SecureRandom.random_bytes(8000)
		tempfile = MiscUtils.make_temp_file(nil,nil,content)
		remote_path = '/content/testfile.bin'
		@client.put_file(tempfile,remote_path)
		tempfile2 = MiscUtils.temp_file
		@client.get_file(remote_path,tempfile2)
		`cmp #{tempfile} #{tempfile2}`.should==''
		@client.delete remote_path
	end

end