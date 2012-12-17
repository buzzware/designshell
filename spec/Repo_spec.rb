require "rspec"
require "rspec_helper"
require "fileutils"

describe "Repo" do

	testFolder = nil
	before do
		testFolder = Dir.mktmpdir('Repo_spec-')
	end

	after do
		FileUtils.rm_rf testFolder if testFolder
	end


	COMMIT_RESULT1 = "[master (root-commit) 6bdd9e1] first commit  1 files changed, 1 insertions(+), 0 deletions(-)  create mode 100644 file1.txt"

	it "commit should create commit object or string message" do
		repo = Dash::Repo.new
		repo.init testFolder

		file1 = File.join(testFolder,'file1.txt')
		content11 = '11111'
		MiscUtils.string_to_file(content11,file1)
		repo.add 'file1.txt'
		commit1 = repo.commit_all('first commit')
		commit1.class.should == Git::Object::Commit

		commit2 = repo.commit_all('second commit without changes')
		commit2.should == nil
	end

	it "create a repo, add file, commit, change, commit, reset, check" do
		repo = Dash::Repo.new
		repo.init testFolder
		repo.path.should == File.expand_path(testFolder)

		file1 = File.join(testFolder,'file1.txt')
		content11 = '11111'
		MiscUtils.string_to_file(content11,file1)
		repo.git.add 'file1.txt'
		commit1 = repo.commit_all('first commit')

		content12 = '11111-some more text'
		MiscUtils.string_to_file(content12,file1)
		commit2 = repo.commit_all('second commit')

		read_content = MiscUtils.string_from_file(file1)
		read_content.should == content12

		repo.reset_hard(commit1)

		read_content = MiscUtils.string_from_file(file1)
		read_content.should == content11
	end

	it "should download a remote repo and check log, then re-open it and check log again" do
		repo = Dash::Repo.new
		repo.clone("git@github.com:buzzware/underscore_plus.git", testFolder)
		repo.path.should == testFolder
		repo.log.first.class.should == Git::Object::Commit

		repo = Dash::Repo.new
		repo.open testFolder
		repo.path.should == testFolder
		repo.log.first.class.should == Git::Object::Commit
	end


end