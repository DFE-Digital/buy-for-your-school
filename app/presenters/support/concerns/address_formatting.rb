module Support
  module Concerns
    module AddressFormatting
      def formatted_address
        address_fields.join(", ")
      end

      def formatted_address_with_name
        ([name] + address_fields).join(", ")
      end

    private

      def address_fields
        %w[street locality town county postcode].map { |key|
          value = address[key]
          value.presence unless value == "Not recorded"
        }.compact
      end
    end
  end
end
