require "rspec"
require "rspec_helper"

describe "DesignShell::Context" do

	it "should find repo path upward" do
		tempdir = MiscUtils.real_path(MiscUtils.make_temp_dir('designshell_context_spec'))
		Dir.mkdir(git_dir = File.join(tempdir,'.git'))
		Dir.mkdir(File.join(tempdir,'one'))
		orange = File.join(tempdir,'one/apple/orange')
		FileUtils.mkpath(orange)
		Dir.mkdir(File.join(tempdir,'two'))
		Dir.chdir(orange)
		context = DesignShell::Context.new({})
		context.pwd.should==orange
		context.find_git_root.should==tempdir
	end
end
