module Support
  class CaseTransferredPresenter < SimpleDelegator
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def body
      "Transferred to framework evaluation #{link_to(framework_evaluation.reference, frameworks_evaluation_path(framework_evaluation), class: 'govuk-link govuk-link--no-visited-state')}"
    end

    def show_additional_data? = false

  private

    def framework_evaluation
      additional_data["destination_type"].safe_constantize.find(additional_data["destination_id"])
    end
  end
end
