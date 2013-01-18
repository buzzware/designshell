require "rspec"
require "rspec_helper"
require "fileutils"

describe "Repo" do

	testFolder = nil
	before do
		testFolder = MiscUtils.real_path(Dir.mktmpdir('Repo_spec-'))
	end

	after do
		FileUtils.rm_rf testFolder if testFolder
	end


	COMMIT_RESULT1 = "[master (root-commit) 6bdd9e1] first commit  1 files changed, 1 insertions(+), 0 deletions(-)  create mode 100644 file1.txt"

	it "commit should create commit object or string message" do
		repo = DesignShell::Repo.new
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
		repo = DesignShell::Repo.new
		repo.init testFolder
		repo.path.should == MiscUtils.real_path(testFolder)

		file1 = File.join(testFolder,'file1.txt')
		content11 = '11111'
		MiscUtils.string_to_file(content11,file1)
		repo.add 'file1.txt'
		repo.changes?.should == true
		commit1 = repo.commit_all('first commit')
		repo.changes?.should == false
		content12 = '11111-some more text'
		MiscUtils.string_to_file(content12,file1)
		repo.changes?.should == true
		commit2 = repo.commit_all('second commit')
		repo.changes?.should == false

		read_content = MiscUtils.string_from_file(file1)
		read_content.should == content12

		repo.reset_hard(commit1)
		repo.changes?.should == false

		read_content = MiscUtils.string_from_file(file1)
		read_content.should == content11
	end

	it "should download a remote repo and check log, then re-open it and check log again" do
		repo = DesignShell::Repo.new
		url = "git@github.com:buzzware/underscore_plus.git"
		repo.clone(url, testFolder)
		repo.path.should == testFolder
		repo.log.first.class.should == Git::Object::Commit

		repo = DesignShell::Repo.new
		repo.open testFolder
		repo.path.should == testFolder
		repo.log.first.class.should == Git::Object::Commit
		repo.origin.url==url
	end

	it "should download a remote repo and get diffs between commits" do
		repo = DesignShell::Repo.new
		url = "git@github.com:buzzware/underscore_plus.git"
		repo.clone(url, testFolder)

		commit1 = "4b133ff8825bbd488ba61fa3e3b82a5fa746ac6a"
		commit2 = "d1b8440dc730ceb4471fbe7c42ccfac94ea12799"
		changes = repo.changesBetweenCommits(commit1,commit2)
		changes.should==["A\tunderscore_plus.js"]
		changes = repo.changesBetweenCommits(commit2,commit1)
		changes.should==["D\tunderscore_plus.js"]
	end

	it "should get contents of a given file from a given commit" do
		repo = DesignShell::Repo.new
		url = "git@github.com:buzzware/underscore_plus.git"
		repo.clone(url, testFolder)

		commit1 = "4b133ff8825bbd488ba61fa3e3b82a5fa746ac6a"
		commit2 = "d1b8440dc730ceb4471fbe7c42ccfac94ea12799"
		file1 = "README.md"
		file2 = "underscore_plus.js"

		readme = repo.get_file_content(file1,commit1)
		readme.is_a?(String).should==true
		readme.size.should > 0
		code = repo.get_file_content(file2,commit1)
		code.should==nil
		code = repo.get_file_content(file2,commit2)
		code.is_a?(String).should==true
		code.size.should > 0
	end

end