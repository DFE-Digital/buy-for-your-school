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
          local_authority = LocalAuthority.find_or_initialize_by(la_code: record[:local_authority][:code]).tap do |la|
            la.name = record[:local_authority][:name]
            la.save!
          end

          Support::Organisation.find_or_initialize_by(urn: record[:urn]).tap do |org|
            org.establishment_type_id = type(record).id
            org.name = record[:school][:name]
            org.address = record[:school][:address]
            org.contact = record[:school][:head_teacher]
            org.phase = record[:school][:phase][:code]
            org.gender = record[:school][:gender][:code]
            org.gor_name = record[:school][:gor_name]
            org.status = record[:establishment_status][:code]
            org.number = record[:school][:number]
            org.rsc_region = record[:rsc_region]
            org.local_authority_legacy = record[:local_authority]
            org.local_authority = local_authority
            org.opened_date = parse_date(record[:school][:opened_date])
            org.closed_date = parse_date(record[:school][:closed_date])
            org.reason_establishment_opened = record[:school][:reason_establishment_opened].presence
            org.reason_establishment_closed = record[:school][:reason_establishment_closed].presence
            org.ukprn = record[:ukprn]
            org.telephone_number = record[:school][:telephone_number]
            org.trust_name = record[:school][:trust_name].presence
            org.trust_code = record[:school][:trust_code].presence
            org.federation_name = record[:federation][:name].presence
            org.federation_code = record[:federation][:code].presence
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
    # @return [true, false]
    def legacy_record?(record)
      Support::Organisation.find_by(urn: record[:urn]).nil? && record[:establishment_status][:code] == 2
    end

    # @param record [Hash]
    #
    # @return [Support::EstablishmentType]
    def type(record)
      Support::EstablishmentType.find_by(code: record[:establishment_type][:code])
    end

    # Some organisations do not have this information on their record and .parse does
    # not like dealing with nil or strings that it can't parse. This method helps
    # to deal with that. The regex is based on the format of the dates used in the file
    # @param opened_date [String] DD-MM-YYYYY
    #
    # @return [Time, nil]
    def parse_date(opened_or_closed_date)
      return nil unless /\d{1,2}-\d{1,2}-\d{4}/.match? opened_or_closed_date

      Time.zone.parse(opened_or_closed_date)
    end
  end
end
