module DesignShell
	module Utils
		def self.lookupItems(aDeployNode, aKeyChain)
			result = {}
			REXML::XPath.each(aDeployNode,'item') do |n|
				name = n.attribute('name').to_s.to_nil
				key = n.attribute('key').to_s.to_nil || name
				next unless name
				if text = n.text.to_nil             # value in node
					result[name] = text
				else                                # value in @params['deploy_creds']
					result[key] = aKeyChain.get(key.to_sym) if key
				end
			end
			result
		end
	end
end