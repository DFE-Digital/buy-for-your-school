# frozen_string_literal: true

module Support
  class CaseHubMigrationFormPresenter < BasePresenter
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # @return [String]
    def category_name
      @category_name ||= Support::Category.find(category_id).title
    end

    # @return [Support::Organisation]
    def establishment
      @establishment ||= Support::Organisation.find_by(urn: school_urn)
    end
  end
end
