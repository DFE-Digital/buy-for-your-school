# frozen_string_literal: true

require_relative "concerns/has_organisation"

module Support
  class CreateCaseFormPresenter < BasePresenter
    include Support::Concerns::HasOrganisation

    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # @return [String]
    def category_name
      return I18n.t("support.case_categorisations.label.none") if category_id.blank?

      @category_name ||= Support::Category.find(category_id).title
    end
  end
end
