require "dry/transformer"

# Transform Framework CSV data into an Array of nested Hashes
#
#
module Support
  module Frameworks
    class Mapper < Dry::Transformer::Pipe
      import Dry::Transformer::ArrayTransformations
      import Dry::Transformer::HashTransformations

      define! do
        map_array do
          rename_keys "Framework" => :name,
                      "FWK Provider" => :supplier,
                      "FAF Category Group" => :category,
                      "Initial Expiry Date on FaF" => :expires_at
        end
      end
    end
  end
end
