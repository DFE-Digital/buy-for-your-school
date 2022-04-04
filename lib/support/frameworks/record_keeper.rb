module Support
  module Frameworks
    # Create/Update an array of Framework records
    #
    # @note Changes to Framework records may impact active cases.
    #
    class RecordKeeper
      def call(records)
        Support::Framework.transaction do
          records.map do |record|
            Support::Framework.find_or_initialize_by(name: record[:name], supplier: record[:supplier]).tap do |framework|
              framework.name = record[:name]
              framework.supplier = record[:supplier]
              framework.category = record[:category]
              framework.expires_at = record[:expires_at]
              framework.save!
            end
          end
        end
      end
    end
  end
end
