String.class_eval do
	# Like bite, but returns the first match instead of the subject
	if !self.instance_methods.include? "extract!"
		def extract!(aValue=$/,aString=self)
			if aValue.is_a? String
				if aString[0,aValue.length] == aValue
					aString[0,aValue.length] = ''
					return aValue
				else
					return nil
				end
			elsif aValue.is_a? Regexp
				if md = aValue.match(aString)
					aString[md.begin(0),md.end(0)-md.begin(0)] = ''
					return md.to_s
				else
					return nil
				end
			else
				return aString
			end
		end
	end
end