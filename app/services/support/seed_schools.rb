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

    def call
      set_establishment_type_codes
      get_persisted_urns
      get_updated_dataset
      update_existing_records
      create_new_records
    end

  private

    # ignore schools we have on record and closed schools that are not on record
    #
    # @param org [Hash<Symbol>]
    def skip?(org)
      @persisted_urns.include?(org[:urn].to_s) || org[:establishment_status][:code] == 2
    end

    # @return [Support::Organisation] create or update by URN
    #
    # @param org [Hash<Symbol>]

    def update_existing_records
      first_batch = true

      Organisation.find_in_batches(batch_size: 2000) do |group|
        Organisation.transaction do
          # Adding this sleep helps with the memory allocation, but if we have less than 2000
          # records to create there seems little point in using it
          sleep(30) unless first_batch
          group.each { |record| update_existing(record) }
          first_batch = false
        end

        GC.start
      end
    end

    def create_new_records
      first_batch = true

      @dataset.reject { |org| skip?(org) }.each_slice(2000) do |slice|
        Organisation.transaction do
          # Adding this sleep helps with the memory allocation, but if we have less than 2000
          # records to create there seems little point in using it
          sleep(30) unless first_batch
          slice.each { |org| create_new(org) }
          first_batch = false
        end

        GC.start
      end
    end

    def update_existing(record)
      org = @dataset.find { |organisation| organisation[:urn].to_s == record.urn.to_s }
      type = @establishment_types.find_by(code: org[:establishment_type][:code])
      record.assign_attributes(
        establishment_type_id: type.id,             # uuid
        name: org[:school][:name],                  # string
        address: org[:school][:address],            # jsonb
        contact: org[:school][:head_teacher],       # jsonb
        phase: org[:school][:phase][:code],         # integer
        gender: org[:school][:gender][:code],       # integer
        status: org[:establishment_status][:code],  # integer
      )

      record.save! if record.changed?
    end

    def create_new(org)
      type = @establishment_types.find_by(code: org[:establishment_type][:code])

      Organisation.create!(
        urn: org[:urn],
        establishment_type_id: type.id,
        name: org[:school][:name],
        address: org[:school][:address],            # jsonb
        contact: org[:school][:head_teacher],       # jsonb
        phase: org[:school][:phase][:code],         # integer
        gender: org[:school][:gender][:code],       # integer
        status: org[:establishment_status][:code],  # integer
      )
    end

    # @return [Array<Hash>] loaded from CSV file or updated live
    def get_updated_dataset
      @dataset = data ? local_dataset.call : live_dataset.call
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

    def set_establishment_type_codes
      @establishment_types = EstablishmentType.select(:code, :id)
    end

    def get_persisted_urns
      @persisted_urns = Organisation.pluck(:urn)
    end
  end
end
