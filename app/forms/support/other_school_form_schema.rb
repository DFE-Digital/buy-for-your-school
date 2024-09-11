# :nocov:
module Support
  class OtherSchoolFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:school_id).value(:string)
      required(:organisation_name).value(:string)
    end

    rule(:school_id) do
      key(:school_id).failure(:missing) if value.blank?
    end

    rule(:organisation_name) do
      # intentional use of organisation_id - the user should only see 1 error around organisation
      key(:school_id).failure(:missing) if value.blank?
    end
  end
end
# :nocov:
