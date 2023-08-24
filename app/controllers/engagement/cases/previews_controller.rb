# frozen_string_literal: true

module Engagement
  module Cases
    class PreviewsController < Engagement::CasesController
      def create
        session.delete :attached_files

        @form = Support::CreateCaseFormPresenter.new(Support::CreateCaseForm.from_validation(validation))
        @files = EngagementCaseUpload.where(upload_reference: @form.upload_reference)
        if validation.success?
          render "engagement/cases/previews/new"
        else
          render "engagement/cases/new"
        end
      end

    private

      def validation
        Support::CreateCaseFormSchema.new.call(**form_params)
      end
    end
  end
end
