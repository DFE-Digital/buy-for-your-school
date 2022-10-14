require "dry/transformer"

# Transform GIAS CSV data into an Array of nested Hashes
#
#
module School
  class Mapper < Dry::Transformer::Pipe
    import Dry::Transformer::ArrayTransformations
    import Dry::Transformer::HashTransformations

    define! do
      map_array do
        rename_keys "UKPRN" => :ukprn, # UK Provider Reference Number
                    "URN" => :urn, # educational establishments (schools)
                    "UPRN" => :uprn,
                    "CHNumber" => :crn, # companies house
                    "RSCRegion (name)" => :rsc_region # RSC region

        # Local Authority
        rename_keys "LA (name)" => :name,
                    "LA (code)" => :code
        nest :local_authority, %i[name code]

        # Local Authority District
        rename_keys "DistrictAdministrative (name)" => :name,
                    "DistrictAdministrative (code)" => :code
        nest :district, %i[name code]

        # Federation
        rename_keys "Federations (name)" => :name,
                    "Federations (code)" => :code
        nest :federation, %i[name code]

        # Administrative Ward
        rename_keys "AdministrativeWard (name)" => :name,
                    "AdministrativeWard (code)" => :code
        nest :ward, %i[name code]

        # Parliamentary Constituency
        rename_keys "ParliamentaryConstituency (name)" => :name,
                    "ParliamentaryConstituency (code)" => :code
        nest :constituency, %i[name code]

        # Establishment Type
        rename_keys "TypeOfEstablishment (name)" => :name,
                    "TypeOfEstablishment (code)" => :code
        nest :establishment_type, %i[name code]

        # Establishment Type Group
        rename_keys "EstablishmentTypeGroup (name)" => :name,
                    "EstablishmentTypeGroup (code)" => :code
        nest :establishment_type_group, %i[name code]

        # Establishment Status
        rename_keys "EstablishmentStatus (name)" => :name,
                    "EstablishmentStatus (code)" => :code
        nest :establishment_status, %i[name code]

        # Phase
        rename_keys "PhaseOfEducation (name)" => :name,
                    "PhaseOfEducation (code)" => :code
        nest :phase, %i[name code]

        # Gender
        rename_keys "Gender (name)" => :name,
                    "Gender (code)" => :code
        nest :gender, %i[name code]

        # Religion
        rename_keys "ReligiousCharacter (name)" => :name,
                    "ReligiousCharacter (code)" => :code
        nest :religion, %i[name code]

        # Age
        rename_keys "StatutoryLowAge" => :lower,
                    "StatutoryHighAge" => :upper
        nest :age, %i[lower upper]

        # Special Needs Support
        nest :special_needs_support, ((1..13).map { |i| "SEN#{i} (name)" })
        map_value :special_needs_support, ->(hash) { hash.values.reject(&:blank?).sort }

        # School Address
        rename_keys "Street" => :street,
                    "Locality" => :locality,
                    "Town" => :town,
                    "County (name)" => :county,
                    "Postcode" => :postcode
        nest :address, %i[street locality town county postcode]

        # Head
        rename_keys "HeadPreferredJobTitle" => :role,
                    "HeadTitle (name)" => :title,
                    "HeadFirstName" => :first_name,
                    "HeadLastName" => :last_name
        nest :head_teacher, %i[role title first_name last_name]

        # School
        # the EstablishmentName may appear multiple times in "edubasealldata"
        # the EstablishmentNumber will be common to many establishments
        rename_keys "EstablishmentName" => :name,
                    "EstablishmentNumber" => :number,
                    # Population
                    "SchoolCapacity" => :student_capacity,
                    "NumberOfPupils" => :student_number,
                    # Contact
                    "TelephoneNum" => :telephone_number,
                    "SchoolWebsite" => :website,
                    # Ofsted
                    "OfstedLastInsp" => :ofsted_last_inspection,
                    "OfstedRating (name)" => :ofsted_rating,
                    # Open date
                    "OpenDate" => :opened_date,
                    # Misc
                    "Trusts (name)" => :trust_name,
                    "Trusts (code)" => :trust_code,
                    "GOR (name)" => :gor_name

        nest :school, %i[
          address
          age
          gender
          gor_name
          religion
          head_teacher
          name
          number
          ofsted_last_inspection
          ofsted_rating
          opened_date
          phase
          student_capacity
          student_number
          telephone_number
          trust_name
          trust_code
          website
        ]
      end
    end
  end
end
