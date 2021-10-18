require "dry-initializer"
require "school/information"

module Support
  #
  # Persist filtered school data from latest public GIAS data or a local file
  #
  # @example
  #   SeedSchools.new(data: "spec/fixtures/gias/example_schools_data.csv").call
  #
  class SeedSchools
    extend Dry::Initializer

    # @return [String] CSV data file path
    option :data, optional: true

    # @return [Array<Organisation>]
    def call
      dataset.each { |org| persist(org) unless skip?(org) }
    end

  private

    # ignore closed schools that are not on record
    # update closed schools if they are on record
    # i.e. change the status of already persisted schools
    #
    # @param org [Hash<Symbol>]
    def skip?(org)
      Organisation.find_by(urn: org[:urn]).nil? && org[:establishment_status][:code] == 2
    end

    # @return [Support::Organisation] create or update by URN
    #
    # @param org [Hash<Symbol>]
    def persist(org)
      type = EstablishmentType.find_by(code: org[:establishment_type][:code])

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

    # @return [Array<Hash>] loaded from CSV file or updated live
    def dataset
      data ? local_dataset.call : live_dataset.call
    end

    # @return [School::Information] filtered from a local file
    def local_dataset
      ::School::Information.new(filter: filter, file: data)
    end

    # @return [School::Information] filtered from a remote file
    def live_dataset
      ::School::Information.new(filter: filter)
    end

    # @return [Hash<String, Array>] criteria to permit
    def filter
      { "TypeOfEstablishment (code)" => EstablishmentType.all.map(&:code) }
    end
  end
end
