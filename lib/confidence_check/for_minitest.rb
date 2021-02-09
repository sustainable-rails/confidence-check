require_relative "check_method"

module ConfidenceCheck
  module ForMinitest
    include ConfidenceCheck::CheckMethod
    def exception_klasses
      [::Minitest::Assertion]
    end

    module WithCapybara
      include ConfidenceCheck::CheckMethod
      include ConfidenceCheck::ForMinitest
      def exception_klasses
        super + [ ::Capybara::CapybaraError ]
      end
    end
  end
end
