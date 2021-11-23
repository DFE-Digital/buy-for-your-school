# frozen_string_literal: true

module Support
  class CaseHubMigrationFormPresenter < BasePresenter
    # @return [String]
    def full_name
      "#{contact_first_name} #{contact_last_name}"
    end

    # @return [String]
    def category_name
      @category_name ||= Support::Category.find(buying_category).title
    end

    # @return [Support::Organisation]
    def establishment
      @establishment ||= Support::Organisation.find_by(urn: school_urn)
    end

    # @return [String]
    def case_source
      Support::Case.sources.key(case_type)
    end
  end
end
