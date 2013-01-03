#!/usr/bin/env ruby

#command = ENV['SSH_ORIGINAL_COMMAND']
#STDERR.write "user #{user} authorized\n"

require "rubygems"
gem 'json'

require 'json'

require 'designshellserver'

#trap("SIGHUP") { abort }


def make_command(aContext,aLine)
	command_name = aLine.scan(/^[A-Z0-9_]+/).pop.to_nil
	return nil unless command_name && DesignShellServer::Command.instance_methods.include?(command_name)
	return DesignShellServer::Command.new(aContext,aLine,command_name)
end


#$stdout.print ARGV.inspect
#$stdout.print ENV.inspect

context = DesignShellServer::Context.new({:argv=>ARGV.clone, :env=>ENV.clone, :stdout=>$stdout, :stdin=>$stdin, :stderr=>$stderr})

$stdout.print "\n>"

$stdin.each_line do |line| line.chomp! "\n"

	command = make_command(context,line)
	command.execute

  $stdout.print "\n>"
end
