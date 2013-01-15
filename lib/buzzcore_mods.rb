MiscUtils.module_eval do
	# Like bite, but returns the first match instead of the subject
	#if !self.instance_methods.include? "extract!"
	#end
	def self.ensure_slashes(aString,aLeading,aTrailing)
		if (aLeading)
			aString = ensure_prefix(aString,'/')
		else
			aString = aString.bite('/')
		end
		if (aTrailing)
			aString = ensure_suffix(aString,'/')
		else
			aString = aString.chomp('/') unless aString=='/' && aLeading
		end
		aString
	end

end