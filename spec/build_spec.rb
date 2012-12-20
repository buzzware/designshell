require "rspec"
require "rspec_helper"

describe "build" do

	testFolder = nil
	before do
		testFolder = Dir.mktmpdir('Repo_spec-')
	end

	after do
		FileUtils.rm_rf testFolder if testFolder
	end

	it "should build source folder into build folder" do
		context = Dash::Context.new()
		dash = Dash::Core.new(:context => context)
		dash.build
	end

	it "should commit the repository" do
		context = Dash::Context.new()
		repo = Dash::Repo.new
		repo.configure()
		repo.clone("git@github.com:buzzware/underscore_plus.git", testFolder)
		dash = Dash::Core.new(:context => context, :repo => repo)
		dash.ensure_repo_open.commit_all(context)
	end
end