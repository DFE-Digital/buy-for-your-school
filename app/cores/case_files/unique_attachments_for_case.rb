module CaseFiles
  class UniqueAttachmentsForCase
    include Enumerable

    def initialize(case_id:)
      @case_id = case_id
    end

    delegate :paginate, to: :query

    def each(&block)
      return to_enum(:each) unless block_given?

      query.each(&block)
    end

  private

    def query
      Support::EmailAttachment
        .unique_files
        .for_case(case_id: @case_id)
        .where(hidden: false)
        .order(is_inline: :asc)
    end
  end
end
