module Support
  class CaseSummaryPresenter < RequestDetailsFormPresenter
    include ActionView::Helpers::TextHelper

    def procurement_stage
      return unless super

      Support::ProcurementStagePresenter.new(super)
    end

    def next_key_date_formatted
      return "-" if next_key_date.blank?

      next_key_date.strftime(date_format)
    end

    def next_key_date_description_formatted
      return "-" if next_key_date_description.blank?

      simple_format(next_key_date_description, class: "govuk-body")
    end
  end
end
