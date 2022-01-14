module MicrosoftGraph
  module Transformer
    class BasePipe < Dry::Transformer::Pipe
      def self.transform(response, into:)
        into.new(**new.call(response))
      end

      def self.transform_collection(response, into:)
        Array(response).map { |item| transform(item, into: into) }
      end
    end
  end
end
