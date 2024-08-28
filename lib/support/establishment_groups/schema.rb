require "app_schema"

module Support
  module EstablishmentGroups
    class Schema < AppSchema
      define do
        required(:name).filled(:string)
        required(:uid).filled(:string)
        required(:ukprn).maybe(:string)
        required(:status).filled(:string)
        required(:group_type_code).filled(:integer)
        required(:opened_date).maybe(:string)
        required(:closed_date).maybe(:string)

        required(:address).hash do
          required(:street).maybe(:string)
          required(:locality).maybe(:string)
          required(:town).maybe(:string)
          required(:county).maybe(:string)
          required(:postcode).maybe(:string)
        end
      end
    end
  end
end
