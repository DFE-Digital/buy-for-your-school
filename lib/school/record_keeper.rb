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
      Support::Organisation.transaction do
        records.map do |record|
          next if legacy_record?(record)

          # This data structure is in active development and not all `record` fields
          # pertain to the "Organisation" model, the structure determined by the
          # "Mapper" and "Schema" can be tweaked to facilitate this and ultimately
          # create more complex entities and associations.
          #
          # The "Organisation" model is a starting point, but in addition an
          # "Establishment" model has been proposed.
          #
          Support::Organisation.find_or_initialize_by(urn: record[:urn]).tap do |org|
            org.establishment_type_id = type(record).id                   # uuid
            org.name = record[:school][:name]                             # string
            org.address = record[:school][:address]                       # jsonb
            org.contact = record[:school][:head_teacher]                  # jsonb
            org.phase = record[:school][:phase][:code]                    # integer
            org.gender = record[:school][:gender][:code]                  # integer
            org.status = record[:establishment_status][:code]             # integer
            org.number = record[:school][:number]                         # string
            org.rsc_region = record[:rsc_region]                          # string
            org.local_authority = record[:local_authority]                # jsonb
            org.open_date = parse_open_date(record[:school][:open_date])  # datetime
            org.ukprn = record[:ukprn]                                    # string
            org.telephone_number = record[:school][:telephone_number]     # string
            org.save!
          end
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

    def parse_open_date(open_date)
      return nil unless /\d{1,2}-\d{1,2}-\d{4}/.match? open_date

      Time.zone.parse(open_date)
    end
  end
end
