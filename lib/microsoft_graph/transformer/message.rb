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
        map_value(:sent_date_time) { to_datetime }
        map_value(:to_recipients) do
          map_array { transform_recipient }
        end
      end
    end
  end
end
