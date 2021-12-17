module MicrosoftGraph
  module Transformer
    class JsonResponse < BasePipe
      import Dry::Transformer::HashTransformations

      define! do
        map_keys ->(k) { Dry::Inflector.new.underscore(k) }
        symbolize_keys
      end
    end
  end
end
