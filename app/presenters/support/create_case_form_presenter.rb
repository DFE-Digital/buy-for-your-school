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

      if other_category.present?
        "#{@category_name} - #{other_category}"
      else
        @category_name
      end
    end

    # @return [String]
    def query_name
      return I18n.t("support.case_categorisations.label.none") if query_id.blank?

      @query_name ||= Support::Query.find(query_id).title

      if other_query.present?
        "#{@query_name} - #{other_query}"
      else
        @query_name
      end
    end

    # @return [String]
    def type
      request_type ? I18n.t("support.case_hub_migration.label.procurement") : I18n.t("support.case_hub_migration.label.non_procurement")
    end
  end
end
