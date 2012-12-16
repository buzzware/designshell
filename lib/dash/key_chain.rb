module Dash
	class KeyChain

		def initialize(aNamespace)
			@keychain = OSXKeychain.new
			@namespace = aNamespace
		end

		def set(aKey,aValue)
			@keychain[@namespace,aKey] = aValue
		end

		def get(aKey)
			@keychain[@namespace,aKey]
		end
	end
end
