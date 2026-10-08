module Energy
  module RegisterYourInterests
    class ErrorSummaryPresenter
      include Rails.application.routes.url_helpers

      def initialize(error_messages)
        @error_messages = error_messages
      end

      def formatted_error_messages
        @error_messages.flat_map do |attribute, messages|
          messages.map { |message| [attribute, message, answer_path(attribute)] }
        end
      end

    private

      def answer_path(attribute)
        path = case attribute
               when :name then energy_register_your_interest_path
               when :email then energy_register_your_interest_email_path
               when :phone_number then energy_register_your_interest_phone_number_path
               when :mat_uid, :mat_name, :ukprn then energy_register_your_interest_mat_path
               when :switch_gas, :gas_contract_end_date then energy_register_your_interest_gas_path
               when :switch_electricity, :electricity_contract_end_date then energy_register_your_interest_electricity_path
               else energy_register_your_interest_check_your_answers_path
               end

        "#{path}?return_to=check-answers"
      end
    end
  end
end
