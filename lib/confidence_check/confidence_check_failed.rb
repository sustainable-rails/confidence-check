require "forwardable"
module ConfidenceCheck
  class ConfidenceCheckedFailed < Exception
    extend Forwardable
    def initialize(exception)
      super("CONFIDENCE CHECK FAILED: #{exception.message}")
      @exception = exception
    end

    def_delegators :@exception, :backtrace, :cause
  end
end


