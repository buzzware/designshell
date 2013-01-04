module DesignShell
	class SiteClient

		attr_reader :deploy_status_file

		def initialize(aContext)
			@context = aContext
			@dav = Net::DAV.new(MiscUtils.append_slash(@context.credentials[:site_url]), :curl => true)
			@dav.verify_server = false
			@dav.credentials(@context.credentials[:site_user],@context.credentials[:site_password])
			@deploy_status_file = '/content/deploy-status.txt'
		end

		DAV_METHODS = [:find]

		def method_missing(sym, *args, &block)
			if @dav && DAV_METHODS.include?(sym)
				@dav.send sym, *args, &block
			else
				super
			end
		end

		def ls(aPath,aRecursive=false)
			result = []
			@dav.find(aPath,:recursive=>aRecursive,:suppress_errors=>false) do | item |
			  result << item.url.to_s.bite(MiscUtils.remove_slash(@context.credentials[:site_url]))
			end
			result
		end

		def get_string(aPath)
			begin
				@dav.get(File.join(@context.credentials[:site_url],aPath))
			rescue Net::HTTPServerException => e
				e.response.is_a?(Net::HTTPNotFound) ? nil : raise
			end
		end

		def put_string(aPath,aString)
			@dav.put_string(File.join(@context.credentials[:site_url],aPath),aString)
		end

		def delete(aPath)
			begin
				@dav.delete(File.join(@context.credentials[:site_url],aPath))
			rescue Net::HTTPServerException => e
				e.response.is_a?(Net::HTTPNotFound) ? nil : raise
			end
		end

		def deploy_status
			s = get_string(deploy_status_file)
			s ? JSON.parse(s) : nil
		end

		def deploy_status=(aObject)
			s = JSON.generate(aObject)
			put_string(deploy_status_file,s)
			aObject
		end

		def put_file(aLocalFile, aRemotePath)
			s = MiscUtils.string_from_file(aLocalFile)
			put_string(aRemotePath,s)
		end

		def get_file(aRemotePath, aLocalFile)
			s = get_string(aRemotePath)
			MiscUtils.string_to_file(s,aLocalFile)
		end

	end
end
