module Support
  module EstablishmentGroups
    # Create/Update an array of EstablishmentGroup records
    #
    # @note Changes to EstablishmnetGroups records may impact active cases.
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
