module DesignShell
	class SiteClient

		attr_accessor :deploy_status_file

		def initialize(aContext)
			@context = aContext
			@server_path = MiscUtils.remove_slash(@context.credentials[:site_url])
			@dav = Net::DAV.new(MiscUtils.append_slash(@server_path), :curl => true)
			@dav.verify_server = false
			@dav.credentials(@context.key_chain.get('site_user'),@context.key_chain.get('site_password'))
			@deploy_status_file = '/content/.deploy-status.txt'
		end

		DAV_METHODS = [:find]

		def method_missing(sym, *args, &block)
			if @dav && DAV_METHODS.include?(sym)
				@dav.send sym, *args, &block
			else
				super
			end
		end

		def full_path(aRelativePath)
			File.join(@server_path,aRelativePath)
		end

		def ls(aPath,aRecursive=false)
			result = []
			@dav.find(aPath,:recursive=>aRecursive,:suppress_errors=>false) do | item |
			  result << item.url.to_s.bite(@server_path)
			end
			result
		end

		def get_string(aPath)
			begin
				@dav.get(full_path(aPath))
			rescue Net::HTTPServerException => e
				e.response.is_a?(Net::HTTPNotFound) ? nil : raise
			end
		end

		def put_string(aPath,aString)
			@dav.put_string(full_path(aPath),aString)
		end

		def delete(aPath)
			begin
				@dav.delete(full_path(aPath))
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

		def upload_files(aLocalDir,aFiles)
			aFiles.each do |f|
				put_file(File.join(aLocalDir,f),f)
			end
		end

		def delete_files(aPaths)
			aPaths.each do |p|
				delete(p)
			end
		end

	end
end
