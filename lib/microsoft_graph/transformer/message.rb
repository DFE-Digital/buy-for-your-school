module MicrosoftGraph
  module Transformer
    class Message < BasePipe
      import Dry::Transformer::ArrayTransformations
      import Dry::Transformer::HashTransformations
      import Dry::Transformer::Coercions
      import :call, from: JsonResponse.new, as: :transform_json_response
      import :call, from: Recipient.new, as: :transform_recipient
      import :call, from: ItemBody.new, as: :transform_body

      define! do
        transform_json_response
        map_value(:body) { transform_body }
        map_value(:from) { transform_recipient }
        map_value(:received_date_time) { to_datetime }
        map_value(:sent_date_time) { to_datetime }
        map_value(:single_value_extended_properties) { map_array { transform_json_response } }
        map_value(:to_recipients) { map_array { transform_recipient } }
        map_value(:cc_recipients) { map_array { transform_recipient } }
        map_value(:bcc_recipients) { map_array { transform_recipient } }
        map_value(:unique_body) { transform_body }
      end
    end
  end
end
