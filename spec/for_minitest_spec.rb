require "spec_helper"
require "minitest"
require "capybara"
require "confidence_check/for_minitest"

RSpec.describe ConfidenceCheck::ForMinitest do
  class IsolateForMinitest
    extend ConfidenceCheck::ForMinitest
    extend Minitest::Assertions
    @assertions = 0
    def self.assertions
      @assertions || 0
    end
    def self.assertions=(new_value)
      @assertions = new_value
    end
  end
  describe "#confidence_check" do
    it "handles ExpectationNotMetError" do
      expect {
        IsolateForMinitest.confidence_check do
          IsolateForMinitest.assert false
        end
      }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
    end
  end
  describe ConfidenceCheck::ForMinitest::WithCapybara do
    class IsolateForMinitestWithCapybara < IsolateForMinitest
      extend ConfidenceCheck::ForMinitest::WithCapybara
    end
    describe "#confidence_check" do
      it "handles ExpectationNotMetError" do
        expect {
          IsolateForMinitestWithCapybara.confidence_check do
            IsolateForMinitest.assert false
          end
        }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
      end
      it "handles Capybara::CapybaraError" do
        expect {
          IsolateForMinitestWithCapybara.confidence_check do
            raise Capybara::ElementNotFound
          end
        }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
      end
    end
  end
end
