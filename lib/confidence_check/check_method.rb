require_relative "confidence_check_failed"

module ConfidenceCheck
  module CheckMethod
    def confidence_check(context=nil, &block)
      if block.nil?
        raise "#confidence_check requires a block"
      end
      block.()
    rescue Exception => ex
      $stdout.puts context.inspect if context
      if exception_klasses.any? {|_| ex.kind_of?(_) }
        raise ConfidenceCheckedFailed.new(ex)
      else
        raise
      end
    end
  end
end
