require "spec_helper"
require "confidence_check/check_method"

RSpec.describe ConfidenceCheck::CheckMethod do
  class MyError < StandardError
  end

  module MyCustomChecks
    def exception_klasses
      [ MyError, ArgumentError ]
    end
    include ConfidenceCheck::CheckMethod
  end

  class IsolateCheckMethod
    extend MyCustomChecks
  end

  describe "#confidence_check" do
    context "when a block is given" do
      context "and the code inside the block raises an error" do
        [
          MyError,
          ArgumentError,
        ].each do |exception_klass|
          context "and that error is #{exception_klass}" do
            it "raises a ConfidenceCheckedFailed" do
              expect {
                IsolateCheckMethod.confidence_check do
                  raise exception_klass, "OH NO"
                end
              }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
            end
            context "when a context was provided" do
              it "prints the context before raising" do
                allow($stdout).to receive(:puts)
                expect {
                  IsolateCheckMethod.confidence_check("some context") do
                    raise exception_klass, "OH NO"
                  end
                }.to raise_error(ConfidenceCheck::ConfidenceCheckedFailed)
                expect($stdout).to have_received(:puts).with("some context".inspect)
              end
            end
          end
        end
        context "but the error is not one we are expecting" do
          it "re-raises the error" do
            expect {
              IsolateCheckMethod.confidence_check do
                raise "WTF"
              end
            }.to raise_error(StandardError,"WTF")
          end
          context "when a context was provided" do
            it "prints the context before raising" do
              allow($stdout).to receive(:puts)
              expect {
                IsolateCheckMethod.confidence_check("some context") do
                  raise "WTF"
                end
              }.to raise_error(StandardError,"WTF")
              expect($stdout).to have_received(:puts).with("some context".inspect)
            end
          end
        end
        context "but the code inside the block does not raise an error" do
          it "does not raise an error" do
            expect {
              IsolateCheckMethod.confidence_check do
                expect(false).to eq(false)
              end
            }.not_to raise_error
          end
        end
      end
      context "when no block is given" do
        it "raises an error" do
          expect {
            IsolateCheckMethod.confidence_check
          }.to raise_error(/requires a block/i)
        end
      end
    end
  end
end
