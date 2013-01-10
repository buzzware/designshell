require "rspec"
require "rspec_helper"

describe "DesignShell" do

	it "deploy_items_values should work" do

		key_chain = DesignShell::KeyChain.new('DesignShellTest')
		context = DesignShell::Context.new(
			:argv=>[],
			:env=>{},
		  :stdout=>$stdout,
		  :stdin=>$stdin,
		  :stderr=>$stderr,
		  :key_chain=>key_chain,
		  :credentials=>Credentials.new('designshell')
		)

deployNodeString = <<EOS
<deployPlan site="testmart.com">
	<plan name="main" branch="master">  <!-- This plan will only work on master branch. Remove branch attribute to apply to any branch -->
		<deploy>
			<kind>BigCommerce</kind>
			<method>WebDav</method>
			<fromPath>/build/bigcommerce</fromPath>
			<toPath>/content/deploy_spec</toPath>
			<item name="site_url">#{context.credentials[:bigcommerce_sandbox_url]}</item> <!-- get this from user creds -->
			<item name="site_username" key="site_user"/>
			<item name="site_password" key="site_password"/>
		</deploy>
	</plan>
</deployPlan>
EOS

		core = DesignShell::Core.new(:context=>context)
		core.deploy_plan(deployNodeString)
		core.deploy_plan.deploy_items_values.should == {
			"site_url" => context.credentials[:bigcommerce_sandbox_url],
			"site_username" => context.key_chain["site_user"],
			"site_password" => context.key_chain["site_password"]
		}
	end


end
