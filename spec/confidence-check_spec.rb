require "spec_helper"

require "confidence-check"

module Capybara
  class ElementNotFound < StandardError
  end
end

RSpec.describe ConfidenceCheck do
  include ConfidenceCheck
  describe "#confidence_check" do
    context "when a block is given" do
      context "and the code inside the block raises an error" do
        context "and that error is RSpec::Expectations::ExpectationNotMetError" do
          it "raises a ConfidenceCheckedFailed" do
            expect {
              confidence_check do
                expect(false).to eq(true)
              end
            }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
          end
          context "when a context was provided" do
            it "prints the context before raising" do
              allow($stdout).to receive(:puts)
              expect {
                confidence_check("some context") do
                  expect(false).to eq(true)
                end
              }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
              expect($stdout).to have_received(:puts).with("some context".inspect)
            end
          end
        end
        context "and that error is Capybara::ElementNotFound" do
          it "raises a ConfidenceCheckedFailed" do
            expect {
              confidence_check do
                raise Capybara::ElementNotFound, "UH OH"
              end
            }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
          end
          context "when a context was provided" do
            it "prints the context before raising" do
              allow($stdout).to receive(:puts)
              expect {
                confidence_check("some context") do
                  raise Capybara::ElementNotFound, "UH OH"
                end
              }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
              expect($stdout).to have_received(:puts).with("some context".inspect)
            end
          end
        end
        context "but the error is not one we are expecting" do
          it "re-raises the error" do
            expect {
              confidence_check do
                raise "WTF"
              end
            }.to raise_error(StandardError,"WTF")
          end
          context "when a context was provided" do
            it "prints the context before raising" do
              allow($stdout).to receive(:puts)
              expect {
                confidence_check("some context") do
                  raise "WTF"
                end
              }.to raise_error(StandardError,"WTF")
              expect($stdout).to have_received(:puts).with("some context".inspect)
            end
          end
        end
      end
      context "but the code inside the block does not raise an error" do
        it "does not raise an error" do
          expect {
            confidence_check do
              expect(false).to eq(false)
            end
          }.not_to raise_error
        end
      end
    end
    context "when no block is given" do
      it "raises an error" do
        expect {
          confidence_check
        }.to raise_error(/requires a block/i)
      end
    end
  end
  describe ConfidenceCheck::ConfidenceCheckedFailed do
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
end
