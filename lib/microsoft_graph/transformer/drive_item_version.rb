module MicrosoftGraph
  module Transformer
    class DriveItemVersion < BasePipe
      import Dry::Transformer::ArrayTransformations
      import Dry::Transformer::HashTransformations
      import Dry::Transformer::Coercions
      import :call, from: JsonResponse.new, as: :transform_json_response

      define! do
        transform_json_response
        map_value(:last_modified_date_time) { to_datetime }
      end
    end
  end
end
