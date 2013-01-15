module DesignShell

	# might have to work on net_dav to support curl with put ie implement request_sending_body
	# http://curb.rubyforge.org/classes/Curl/Easy.html
	#

	class SiteClient

		attr_accessor :deploy_status_file

		def initialize(aConfig)
			#@context = aContext
			@server_path = MiscUtils.remove_slash(aConfig[:site_url])
			site_username = aConfig[:site_username]
			site_password = aConfig[:site_password]

			@dav = Net::DAV.new(MiscUtils.append_slash(@server_path), :curl => false)
			@dav.verify_server = false
			@dav.credentials(site_username,site_password)
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

		def ls(aPath=nil,aRecursive=false)
			result = []
			path = MiscUtils.append_slash(full_path(aPath||''))
			@dav.find(path,:recursive=>aRecursive,:suppress_errors=>false) do | item |
			  result << item.url.to_s.bite(path)
			end
			result
		end

		def list_files(aPath=nil,aRecursive=false)
			result = ls(aPath,aRecursive)
			result.delete_if {|f| f.ends_with? '/'}
			result
		end

		def get_string(aPath)
			begin
				@dav.get(full_path(aPath))
			rescue Net::HTTPServerException => e
				e.response.is_a?(Net::HTTPNotFound) ? nil : raise
			rescue Net::HTTPError => e
				e.message.index('404') ? nil : raise
			end
		end

		def put_string(aPath,aString)
			@dav.put_string(full_path(aPath),aString)
		end

		def ensure_folder_path(aPath)
			path_parts = aPath.bite('/').chomp('/').split('/')
			last_part = path_parts.length-1
			existing_part = nil
			last_part.downto(0) do |i|
				existing_part = i if !existing_part && exists?(path = '/'+path_parts[0..i].join('/'))
			end
			(existing_part ? existing_part+1 : 0).upto(last_part) do |i|
				mkdir('/'+path_parts[0..i].join('/'))
			end
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
			if aObject
				s = JSON.generate(aObject)
				put_string(deploy_status_file,s)
			else
				delete deploy_status_file
			end
			aObject
		end

		def put_file(aLocalFile, aRemotePath, aEnsureFolder=true)
			s = MiscUtils.string_from_file(aLocalFile)
			ensure_folder_path(File.dirname(aRemotePath)) if aEnsureFolder
			put_string(aRemotePath,s)
		end

		def get_file(aRemotePath, aLocalFile)
			s = get_string(aRemotePath)
			MiscUtils.string_to_file(s,aLocalFile)
		end

		def upload_files(aLocalDir,aFiles,aFromPath=nil,aToPath=nil)
			aFiles.each do |f|
				to = f
				to = MiscUtils.path_rebase(to,aFromPath,aToPath) if aFromPath && aToPath
				put_file(File.join(aLocalDir,f),to)
			end
		end

		def delete_files(aPaths,aFromPath=nil,aToPath=nil)
			if (aFromPath && aToPath)
				aPaths.each do |p|
					delete(MiscUtils.path_rebase(p,aFromPath,aToPath))
				end
			else
				aPaths.each do |p|
					delete(p)
				end
			end
		end

		def exists?(aPath)
			@dav.exists? full_path(aPath)
		end

		def mkdir(aPath)
			@dav.mkdir full_path(aPath)
		end

	end
end
