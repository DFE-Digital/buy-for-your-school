require "dry-initializer"
require "school/information"

module Support
  #
  # Persist school data from latest public GIAS data
  #
  # @example
  #   SeedSchools.new(data: "spec/fixtures/gias/example_schools_data.csv").call
  #
  class SeedSchools
    extend Dry::Initializer

    # @return [String] CSV data file path
    option :data, optional: true

    # @return [Array<Hash>]
    #
    def call
      # ~40k (supported) / ~400k (total)
      source.each do |org|
        type = EstablishmentType.find_by(code: org[:establishment_type][:code])

        # skip unsupported establishment type (90%)
        next unless type

        # change the status of already persisted schools
        # but skip closed establishments (~18k)
        if Organisation.find_by(urn: org[:urn]).nil? && org[:establishment_status][:code] == 2
          next
        end

        # supported and open ~22k
        Organisation.find_or_create_by!(urn: org[:urn]) do |record|
          record.establishment_type_id = type.id             # uuid
          record.name = org[:school][:name]                  # string
          record.address = org[:school][:address]            # jsonb
          record.contact = org[:school][:head_teacher]       # jsonb
          record.phase = org[:school][:phase][:code]         # integer
          record.gender = org[:school][:gender][:code]       # integer
          record.status = org[:establishment_status][:code]  # integer
        end
      end
    end

  private

    # @return [Array<Hash>] loaded from CSV file or updated live
    def source
      if data
        ::School::Information.new(file: data).call
      else
        ::School::Information.new.call
      end
    end
  end
end
