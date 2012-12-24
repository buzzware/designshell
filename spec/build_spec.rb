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
		context = DesignShell::Context.new()
		ds = DesignShell::Core.new(:context => context)
		ds.build
	end

	it "should commit the repository" do
		context = DesignShell::Context.new()
		repo = DesignShell::Repo.new
		repo.configure()
		repo.clone("git@github.com:buzzware/underscore_plus.git", testFolder)
		ds = DesignShell::Core.new(:context => context, :repo => repo)
		ds.ensure_repo_open.commit_all(context)
	end
end