module Engagement
  class CasesController < ::Engagement::ApplicationController
    before_action :filter_forms, only: %i[index]
    before_action :current_case, only: %i[show]

    include Support::Concerns::HasInteraction
    include Support::Concerns::FilterParameters

    def index
      session.delete(:back_link)

      respond_to do |format|
        format.json do
          @cases = CaseSearch.omnisearch(params[:q])
        end

        format.html do
          @cases = @all_cases_filter_form.results.paginate(page: params[:cases_page])
        end
      end
    end

    def new
      @form = Support::CreateCaseForm.new
      @back_url = engagement_cases_path
    end

    def create
      @form = Support::CreateCaseForm.from_validation(validation)
      @form.creator = current_agent

      if validation.success? && params[:button] == "create"
        kase = @form.create_case

        CaseFiles::SubmitCaseUpload.new.call(upload_reference: @form.upload_reference, support_case_id: kase.id)

        create_interaction(kase.id, "create_case", "Case created", @form.to_h.slice(:source, :category))

        redirect_to engagement_cases_path
      else
        render :new
      end
    end

    def show
      session[:back_link] = url_from(back_link_param) unless back_link_param.nil?
      @back_url = url_from(back_link_param) || session[:back_link] || engagement_cases_path
    end

  private

    def current_case
      @current_case ||= Support::CasePresenter.new(Support::Case.find_by(id: params[:id]))
    end

    def filter_forms
      @all_cases_filter_form = Support::Case.created_by_e_and_o.filtering(filter_params_for(:filter_all_cases_form))
    end

    def validation
      Support::CreateCaseFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:create_case_form).permit(
        :organisation_id,
        :organisation_name,
        :organisation_type,
        :organisation_urn,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :extension_number,
        :discovery_method,
        :discovery_method_other_text,
        :category_id,
        :query_id,
        :other_category,
        :other_query,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :progress_notes,
        :request_type,
        :request_text,
        :procurement_amount,
        :upload_reference,
        :blob_attachments,
        file_attachments: [],
      ).merge({
        source: :engagement_and_outreach_cms.to_s,
        creation_source: :engagement_and_outreach_team.to_s,
      })
    end
  end
end
