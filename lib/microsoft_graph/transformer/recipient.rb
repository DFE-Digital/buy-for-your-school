module MicrosoftGraph
  module Transformer
    class Recipient < BasePipe
      import Dry::Transformer::HashTransformations
      import :call, from: JsonResponse.new, as: :transform_json_response
      import :call, from: EmailAddress.new, as: :transform_email_address

      define! do
        transform_json_response
        map_value(:email_address) { transform_email_address }
      end
    end
  end
end
