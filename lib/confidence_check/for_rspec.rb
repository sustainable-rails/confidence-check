require_relative "check_method"

module ConfidenceCheck
  module ForRSpec
    include ConfidenceCheck::CheckMethod
    def exception_klasses
      [::RSpec::Expectations::ExpectationNotMetError ]
    end

    module WithCapybara
      include ConfidenceCheck::CheckMethod
      include ConfidenceCheck::ForRSpec
      def exception_klasses
        super + [ ::Capybara::CapybaraError ]
      end
    end
  end
end
