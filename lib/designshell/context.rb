module DesignShell

	class Context
		attr_reader :global_options,:options,:pwd,:argv,:env,:stdout,:stdin,:stderr,:credentials,:key_chain
		attr_writer :pwd

		def initialize(aValues=nil)
			return if !aValues
			@global_options = aValues[:global_options]
			@options = aValues[:options]
			@pwd = MiscUtils.real_path(Dir.pwd)
			@argv = aValues[:argv]
			@env = aValues[:env]
			@stdout = aValues[:stdout]
			@stdin = aValues[:stdin]
			@stderr = aValues[:stderr]
			@credentials = aValues[:credentials]
			@key_chain = aValues[:key_chain]
		end

		# http://thinkingdigitally.com/archive/capturing-output-from-puts-in-ruby/
		#class SimpleSemParserTest < Test::Unit::TestCase
		#  def test_set_stmt_write
		#    out = capture_stdout do
		#      parser = SimpleSemParser.new
		#      parser.parse('set write, "Hello World!"').execute
		#    end
		#    assert_equal "Hello World!\n", out.string
		#  end
		#end
		def capture_stdout
			stdout_before = @stdout
			out = StringIO.new
      @stdout = out
      yield
      return out.string
    ensure
      @stdout = stdout_before
    end

		def find_git_root
			git_folder = MiscUtils.find_upwards(@pwd,'.git')
			return git_folder && git_folder.chomp('/.git')
		end

	end

end
