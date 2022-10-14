require "app_schema"

module School
  # Coerce and validate transformed GIAS data
  #
  class Schema < AppSchema
    define do
      # required(:ukprn).filled(:integer, digits?: 8)
      # required(:urn).filled(:integer, digits?: 6)
      # required(:uprn).filled(:integer, digits?: 7..12)

      required(:ukprn).filled(:integer)
      required(:urn).filled(:integer)
      required(:uprn).filled(:integer)
      required(:crn).maybe(:string)
      required(:rsc_region).maybe(:string)

      required(:local_authority).hash do
        required(:code).filled(:integer)
        required(:name).filled(:string)
      end

      required(:district).hash do
        required(:code).filled(:string)
        required(:name).filled(:string)
      end

      required(:federation).hash do
        required(:code).filled(:integer)
        required(:name).filled(:string)
      end

      required(:ward).hash do
        required(:code).filled(:string)
        required(:name).filled(:string)
      end

      required(:constituency).hash do
        required(:code).filled(:string)
        required(:name).filled(:string)
      end

      required(:establishment_type).hash do
        required(:code).filled(:integer)
        required(:name).filled(:string)
      end

      required(:establishment_status).hash do
        required(:code).filled(:integer)
        required(:name).filled(:string)
      end

      required(:establishment_type_group).hash do
        required(:code).filled(:integer)
        required(:name).filled(:string)
      end

      required(:school).hash do
        required(:phase).hash do
          required(:code).filled(:integer)
          required(:name).filled(:string)
        end

        required(:gender).hash do
          required(:code).filled(:integer)
          required(:name).filled(:string)
        end

        required(:gor_name).filled(:string)

        required(:religion).hash do
          required(:code).filled(:integer)
          required(:name).filled(:string)
        end

        required(:age).hash do
          required(:lower).filled(:integer)
          required(:upper).filled(:integer)
        end

        required(:address).hash do
          required(:street).filled(:string)
          required(:locality).filled(:string)
          required(:town).filled(:string)
          required(:county).filled(:string)
          required(:postcode).filled(:string)
        end

        required(:head_teacher).hash do
          required(:role).filled(:string)
          required(:title).filled(:string)
          required(:first_name).filled(:string)
          required(:last_name).filled(:string)
        end

        required(:name).filled(:string)
        required(:number).filled(:integer)
        required(:ofsted_rating).filled(:string)
        required(:ofsted_last_inspection).filled(:date)
        required(:student_capacity).filled(:integer)
        required(:student_number).filled(:integer)
        required(:website).filled(:string)
        required(:telephone_number).filled(:string)
        required(:trust_name).filled(:string)
        required(:trust_code).filled(:string)
        required(:opened_date).maybe(:string)
      end
    end
  end
end
