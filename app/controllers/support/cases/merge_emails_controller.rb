module Support
  class Cases::MergeEmailsController < Cases::ApplicationController
    before_action :from_case
    before_action :to_case, except: %i[new]
    before_action :stage, only: %i[create]

    def new
      clear_session
      @back_url = support_cases_url
      @stage = :search
      @merge_emails_form = CaseMergeEmailsForm.new
    end

    def create
      @merge_emails_form = CaseMergeEmailsForm.from_validation(validation)

      case stage

      when :search
        @back_url = support_cases_url

      when :preview
        @back_url = new_support_case_merge_emails_path

      when :merge
        MergeCaseEmails.new(
          from_case: from_case.__getobj__,
          to_case: to_case.__getobj__,
          agent: current_agent,
        ).call

        return redirect_to support_case_merge_emails_path(from_case)
      end

      render :new
    end

    def show; end

  private

    def stage
      @stage ||= if validation&.success? && merge_emails_params[:confirmation]
                   :merge
                 elsif validation&.success?
                   :preview
                 else
                   :search
                 end
    end

    def from_case
      @from_case ||= CasePresenter.new(current_case)
    end

    def to_case
      @to_case ||= CasePresenter.new(
        Case.find_by(ref: to_case_ref),
      )
    end

    def to_case_ref
      if params[:merge_emails_form] && merge_emails_params[:merge_into_case_ref].present?
        session[:merge_into_case_ref] = merge_emails_params[:merge_into_case_ref]
      else
        session[:merge_into_case_ref]
      end
    end

    def clear_session
      session.delete(:merge_into_case_ref)
    end

    def validation
      @validation ||= CaseMergeEmailsFormSchema.new.call(**merge_emails_params, merge_from_case_ref: from_case.ref)
    end

    def merge_emails_params
      params.require(:merge_emails_form).permit(:merge_into_case_ref, :confirmation)
    end
  end
end
