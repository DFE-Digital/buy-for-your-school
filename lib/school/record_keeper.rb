# TODO: move into the Support namespace
module School
  # Create/Update an array of school records
  #
  # @note Changes to school records may impact active cases.
  #
  class RecordKeeper
    # @param records [Array<Hash>]
    def call(records)
      # OPTIMIZE: opportunity to wrap in a transaction block
      records.map do |record|
        if legacy_record?(record)
          # puts "School URN: #{record[:urn]} is already closed"
          next
        end

        # This data structure is in active development and not all `record` fields
        # pertain to the "Organisation" model, the structure determined by the
        # "Mapper" and "Schema" can be tweaked to facilitate this and ultimately
        # create more complex entities and associations.
        #
        # The "Organisation" model is a starting point, but in addition an
        # "Establishment" model has been proposed.
        #
        Support::Organisation.find_or_create_by!(urn: record[:urn]) do |org|
          org.establishment_type_id = type(record).id        # uuid
          org.name = record[:school][:name]                  # string
          org.address = record[:school][:address]            # jsonb
          org.contact = record[:school][:head_teacher]       # jsonb
          org.phase = record[:school][:phase][:code]         # integer
          org.gender = record[:school][:gender][:code]       # integer
          org.status = record[:establishment_status][:code]  # integer
        end
      end
    end

  private

    # ignore closed schools that are not on record
    # update closed schools if they are on record
    # i.e. change the status of already persisted schools
    #
    # @param record [Hash]
    #
    # @return [Support::Organisation]
    def legacy_record?(record)
      Support::Organisation.find_by(urn: record[:urn]).nil? && record[:establishment_status][:code] == 2
    end

    # @param record [Hash]
    #
    # @return [Support::EstablishmentType]
    def type(record)
      Support::EstablishmentType.find_by(code: record[:establishment_type][:code])
    end
  end
end
