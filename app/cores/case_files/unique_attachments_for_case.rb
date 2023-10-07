module CaseFiles
  class UniqueAttachmentsForCase
    include Enumerable

    def initialize(case_id:, filter_results: "all")
      @case_id = case_id
      @filter_results = filter_results
    end

    delegate :paginate, to: :query

    def each(&block)
      return to_enum(:each) unless block_given?

      query.each(&block)
    end

  private

    def filter_to_apply
      case @filter_results
      when "received"
        { email: { folder: :inbox } }
      when "sent"
        { email: { folder: :sent_items } }
      else
        {}
      end
    end

    def query
      Support::EmailAttachment
        .for_case(case_id: @case_id)
        .where(hidden: false, **filter_to_apply)
        .unique_files
        .reorder(is_inline: :asc, created_at: :desc)
    end
  end
end
