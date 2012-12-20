require "rspec"
require "rspec_helper"
require "fileutils"

describe "RepoServer" do

	testFolder = nil
	before do
		testFolder = Dir.mktmpdir('Repo_spec-')

		cred = Credentials.new(:dash)

	end

	after do
		FileUtils.rm_rf testFolder if testFolder
	end

	it "should list repos" do
		keyChain = Dash::KeyChain.new('Dash')
		#keyChain.set({
		#	:oauth_token => 'OAuth consumer Key',
		#	:oauth_secret => 'OAuth consumer Secret',
		#  :login => 'username, not email address',
		#  :password => 'user password'
		#},'RepoServer.')
		repoServer = Dash::RepoServer.new
		values = keyChain.get([:oauth_token,:oauth_secret,:login,:password],'RepoServer.').symbolize_keys
		repoServer.setup(values)

		result = repoServer.repos    #"[#<Hashie::Mash is_private=true name="test1" owner="buzzware" scm="git" slug="test1">]"
		result.class.should==Array
		result.length.should > 0
		result.first.scm.should=='git'
	end

	it "should clone the first repo" do
		keyChain = Dash::KeyChain.new('Dash')
		repoServer = Dash::RepoServer.new
		values = keyChain.get([:oauth_token,:oauth_secret,:login,:password],'RepoServer.').symbolize_keys
		repoServer.setup(values)
		repos = repoServer.repos
		repos.length.should > 0
		repo = repos && repos.first

		url = "git@bitbucket.org:#{repo.owner}/#{repo.slug}.git"
		repo = Dash::Repo.new
		result = repo.clone(url, testFolder)
		repo.path.should == testFolder
		repo.branches.class.should == Git::Branches
	end

end