require "spec_helper"
require "capybara"
require "confidence_check/for_rspec"

RSpec.describe ConfidenceCheck::ForRSpec do
  class IsolateForRSpec
    extend ConfidenceCheck::ForRSpec
  end
  describe "#confidence_check" do
    it "handles ExpectationNotMetError" do
      expect {
        IsolateForRSpec.confidence_check do
          expect(false).to eq(true)
        end
      }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
    end
    it "handles MultipleExpectationsNotMetError" do
      expect {
        IsolateForRSpec.confidence_check do
          aggregate_failures do
            expect(false).to eq(true)
            expect(true).to eq(false)
          end
        end
      }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
    end
  end
  describe "with Capybara" do
    class IsolateForRSpecWithCapybara
      extend ConfidenceCheck::ForRSpec::WithCapybara
    end
    describe "#confidence_check" do
      it "handles Capybara::CapybaraError" do
        expect {
          IsolateForRSpecWithCapybara.confidence_check do
            raise Capybara::ElementNotFound
          end
        }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
      end
      it "handles ExpectationNotMetError" do
        expect {
          IsolateForRSpecWithCapybara.confidence_check do
            expect(false).to eq(true)
          end
        }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
      end
      it "handles MultipleExpectationsNotMetError" do
        expect {
          IsolateForRSpecWithCapybara.confidence_check do
            aggregate_failures do
              expect(false).to eq(true)
              expect(true).to eq(false)
            end
          end
        }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
      end
    end
  end
end
