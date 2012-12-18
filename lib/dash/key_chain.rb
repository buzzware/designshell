module Dash
	class KeyChain

		def initialize(aNamespace)
			@keychain = OSXKeychain.new
			@namespace = aNamespace
		end

		def set(aKey,aValue=nil,aPrefix='')
			if (aKey.is_a?(String) || aKey.is_a?(Symbol))
				@keychain[@namespace,aPrefix.to_s+aKey.to_s] = aValue
			elsif aKey.is_a?(Object)
				prefix = aValue || aPrefix
				aKey.each {|k,v| set(k,v,prefix)}
			end
		end

		def get(aKey,aPrefix=nil,aKeepPrefix=false)
			if (aKey.is_a?(Array))
				result = {}
				aKey.each do |k|
					storeKey = (aKeepPrefix ? aPrefix.to_s+k.to_s : k.to_s)
					v = get(k.to_s,aPrefix)
					result[storeKey] = v
				end
				return result
			else
				return @keychain[@namespace,aPrefix.to_s+aKey.to_s]
			end
		end
	end
end
