require 'bitbucket_rest_api'

module Dash
	class RepoServer

		DELEGATE_METHODS = [:user,:oauth_token,:oauth_secret,:basic_auth,:login,:password,:adapter,:adapter=,:setup]

		def initialize
			@bitbucket = BitBucket::Client.new({})
		end

		def method_missing(sym, *args, &block)
			if @bitbucket && DELEGATE_METHODS.include?(sym)
				@bitbucket.send sym, *args, &block
			else
				super
			end
		end

		def repos
			@bitbucket.repos.all
		end

	end
end