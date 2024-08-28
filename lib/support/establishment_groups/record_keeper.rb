module Support
  module EstablishmentGroups
    # Create/Update an array of EstablishmentGroup records
    #
    # @note Changes to EstablishmentGroups records may impact active cases.
    # Creates ~5k Support::EstablishmentGroup records
    #
    class RecordKeeper
      def call(records)
        Support::EstablishmentGroup.transaction do
          records.map do |record|
            Support::EstablishmentGroup.find_or_initialize_by(uid: record[:uid]).tap do |group|
              group.name = record[:name]
              group.establishment_group_type = group_type(record)
              group.ukprn = record[:ukprn]
              group.status = record[:status].downcase
              group.opened_date = record[:opened_date]
              group.closed_date = record[:closed_date]
              group.address = record[:address]
              group.save!
            end
          end
        end
      end

    private

      # @param record [Hash]
      #
      # @return [Support::EstablishmentGroupType]
      def group_type(record)
        Support::EstablishmentGroupType.find_by(code: record[:group_type_code])
      end
    end
  end
end
