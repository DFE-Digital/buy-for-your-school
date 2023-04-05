module Support
  module Forms
    class ValidateProcurementAmount
      attr_reader :amount

      def initialize(amount)
        @amount = amount&.gsub(/[£,]/, "")
      end

      def invalid_number?
        return false if @amount.blank?

        false if Float(@amount)
      rescue ArgumentError
        true
      end

      def too_large?
        return false if @amount.blank?

        Float(@amount) >= 10**7
      rescue ArgumentError
        false
      end
    end
  end
end
