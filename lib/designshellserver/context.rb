module DesignShellServer

	class Context
		attr_reader :argv,:env,:stdout,:stdin,:stderr

		def initialize(aValues)
			return if !aValues
			@argv = aValues[:argv]
			@env = aValues[:env]
			@stdout = aValues[:stdout]
			@stdin = aValues[:stdin]
			@stderr = aValues[:stderr]
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

	end

end
