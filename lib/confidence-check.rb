require "forwardable"
require "rspec"

module ConfidenceCheck
  VERSION = "1.0.0"
  class ConfidenceCheckedFailed < ::RSpec::Expectations::ExpectationNotMetError
    extend Forwardable
    def initialize(exception)
      super("CONFIDENCE CHECK FAILED: #{exception.message}")
      @exception = exception
    end

    def_delegators :@exception, :backtrace, :cause
  end

  def confidence_check(context=nil, &block)
    if block.nil?
      raise "#confidence_check requires a block"
    end
    block.()
  rescue ::RSpec::Expectations::ExpectationNotMetError, Capybara::ElementNotFound => ex
    $stdout.puts context.inspect if context
    raise ConfidenceCheckedFailed.new(ex)
  rescue Exception
    $stdout.puts context.inspect if context
    raise
  end
end
