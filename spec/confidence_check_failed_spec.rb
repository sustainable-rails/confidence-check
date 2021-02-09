require "spec_helper"
require "confidence_check/confidence_check_failed"

RSpec.describe ConfidenceCheck::ConfidenceCheckedFailed do
  def raised_exception
    expect(false).to eq(true)
  rescue Exception => ex
    ex
  end

  describe "#message" do
    it "indicates the failure is due to a confidence check not a test failure" do
      actual_exception = raised_exception
      exception = ConfidenceCheck::ConfidenceCheckedFailed.new(actual_exception)
      expect(exception.message).to eq("CONFIDENCE CHECK FAILED: #{actual_exception.message}")
    end
  end
  describe "#backtrace" do
    it "delegates to the caught exception" do
      actual_exception = raised_exception
      exception = ConfidenceCheck::ConfidenceCheckedFailed.new(actual_exception)
      expect(exception.backtrace).to be(actual_exception.backtrace)
    end
  end
  describe "#cause" do
    it "delegates to the caught exception" do
      actual_exception = raised_exception
      exception = ConfidenceCheck::ConfidenceCheckedFailed.new(actual_exception)
      expect(exception.cause).to be(actual_exception.cause)
    end
  end
end
