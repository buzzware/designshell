require "rspec"

describe "build" do

	it "should build source folder into build folder" do
		context = Context.new(args)
		dash = Dash.new(context)
		dash.build(context)
	end

	it "should commit the repository" do
		context = Context.new(args)
		dash = Dash.new(context)
		dash.ensure_repo_open.commit(context)
	end
end