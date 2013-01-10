module DesignShell
	class DeployPlan
		def initialize(aConfig=nil)
			return if !aConfig
			@core = aConfig[:core]
			read(aConfig[:plan]) if aConfig[:plan]
		end

		def read(aDeployPlan)
			@deployPlanNode = XmlUtils.get_xml_root(aDeployPlan)
		end

		def site
			XmlUtils.peek_node_value(@deployPlanNode,'/deployPlan/@site')
		end

		def deploy_node()  # later accept criteria
			XmlUtils.single_node(@deployPlanNode,'/deployPlan/plan/deploy')
		end

		def key_chain
			@core && @core.context && @core.context.key_chain
		end

		def deploy_items_values(aDeployNode=nil)
			aDeployNode ||= deploy_node()
			result = {}
			aDeployNode.get_elements('item').each do |n|
				next unless name = XmlUtils.attr(n,'name')
				if text = n.text.to_nil # value in node
					result[name] = text
				elsif key_chain                   # value in keyChain
					key = XmlUtils.attr(n,'key') || name
					result[name] = key_chain[key]
				end
			end
			result
		end
	end
end
