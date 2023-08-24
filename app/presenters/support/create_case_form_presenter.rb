# frozen_string_literal: true

require_relative "concerns/has_organisation"

module Support
  class CreateCaseFormPresenter < RequestDetailsFormPresenter
    include Support::Concerns::HasOrganisation
    include ActionView::Helpers::NumberHelper

    def attachments
      file_attachments
    end

    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    def procurement_amount
      return "" if super.blank?

      number_to_currency(super, unit: "£", precision: 2)
    end
  end
end
