# frozen_string_literal: true

module Engagement
  class Cases::PreviewsController < Engagement::CasesController
    def create
      @form = Support::CreateCaseFormPresenter.new(Support::CreateCaseForm.from_validation(validation))
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
