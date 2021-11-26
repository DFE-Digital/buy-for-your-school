module Support
  class Cases::CategorisationsController < Cases::ApplicationController
    before_action :set_back_url, :set_categories

    def edit
      @case_categorisation_form = CaseCategorisationForm.new(category_id: current_case.category_id)
    end

    def update
      @case_categorisation_form = CaseCategorisationForm.from_validation(validation)

      if validation.success?
        current_case.update!(category_id: @case_categorisation_form.category_id)

        record_action(case_id: current_case.id, action: "change_category", data: { category_title: current_case.category.title })

        redirect_to @back_url, notice: I18n.t("support.case_categorisations.flash.updated")
      else
        render :edit
      end
    end

  private

    def set_categories
      @categories = Support::Category.top_level.ordered_by_title
    end

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end

    def validation
      CaseCategorisationFormSchema.new.call(**case_categorisation_form_params)
    end

    def case_categorisation_form_params
      params.require(:case_categorisation_form).permit(:category_id)
    end
  end
end
