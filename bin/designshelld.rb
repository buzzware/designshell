#!/usr/bin/env ruby

#command = ENV['SSH_ORIGINAL_COMMAND']
#STDERR.write "user #{user} authorized\n"

require "rubygems"

require 'designshellserver'

#trap("SIGHUP") { abort }

context = DesignShell::Context.new({
	:argv=>ARGV.clone,
	:env=>ENV.clone,
	:stdout=>$stdout,
	:stdin=>$stdin,
	:stderr=>$stderr,
  :credentials=>Credentials.new('DesignShellServer')
})
core = DesignShellServer::Core.new(context)
core.run

