require "dry/transformer"

# Transform GIAS CSV data into an Array of nested Hashes
#
#
module Support
  module EstablishmentGroups
    class Mapper < Dry::Transformer::Pipe
      import Dry::Transformer::ArrayTransformations
      import Dry::Transformer::HashTransformations

      define! do
        map_array do
          rename_keys "Group UID" => :uid, # Unique reference from GIAS groups data
                      "UKPRN" => :ukprn, # UK Provider Reference Number
                      "Group Name" => :name,
                      "Group Type (code)" => :group_type_code,
                      "Group Status (code)" => :status,
                      "Open date" => :opened_date,
                      "Closed Date" => :closed_date

          # School Address
          rename_keys "Group Street" => :street,
                      "Group Locality" => :locality,
                      "Group Town" => :town,
                      "Group County" => :county,
                      "Group Postcode" => :postcode
          nest :address, %i[street locality town county postcode]
        end
      end
    end
  end
end
