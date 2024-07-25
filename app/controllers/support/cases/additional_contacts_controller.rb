module Support
  class Cases::AdditionalContactsController < Cases::ApplicationController
    before_action :set_current_case, only: %i[create update edit new]
    before_action :set_additional_contact, only: %i[edit update destroy]
    before_action :set_additional_contacts, only: %i[index]
    before_action :get_emails_of_contacts, only: %i[create update]

    def index; end

    def new
      @case_additional_contact_form = CaseAdditionalContactForm.new(@current_case)
    end

    def create
      @case_additional_contact_form = CaseAdditionalContactForm.from_validation(validation)
      @current_case = Support::Case.find(case_additional_contact_form_params[:support_case_id]) if @current_case.blank?
      if validation.success? && !@emails.include?(case_additional_contact_form_params[:email])
        Support::CaseAdditionalContact.create!(case_additional_contact_form_params)
        redirect_to support_case_additional_contacts_path(case_id: @current_case.id), notice: I18n.t("support.case_contact_details.flash.success")
      else
        flash[:error] = { message: I18n.t("support.case_contact_details.flash.already_a_contact"), class: "govuk-error" } if @emails.include?(case_additional_contact_form_params[:email])
        render :new
      end
    end

    def edit
      @case_additional_contact_form = CaseAdditionalContactForm.from_case(@additional_contact)
    end

    def update
      @case_additional_contact_form = CaseAdditionalContactForm.from_validation(validation)
      @emails.delete(@additional_contact.email)
      if validation.success? && !@emails.include?(case_additional_contact_form_params[:email])
        @additional_contact.update!(case_additional_contact_form_params)
        redirect_to support_case_additional_contacts_path(case_id: @current_case.id), notice: I18n.t("support.case_contact_details.flash.update_success") if @additional_contact.update(case_additional_contact_form_params)

      else
        flash[:error] = { message: I18n.t("support.case_contact_details.flash.already_a_contact"), class: "govuk-error" } if @emails.include?(case_additional_contact_form_params[:email])
        render :edit
      end
    end

    def destroy
      @additional_contact.destroy!
      redirect_to support_case_additional_contacts_path(case_id: @current_case.id), notice: I18n.t("support.case_contact_details.flash.destroyed")
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def validation
      CaseAdditionalContactFormSchema.new.call(**case_additional_contact_form_params)
    end

    def set_additional_contact
      @additional_contact = Support::CaseAdditionalContact.find(params[:id])
    end

    def set_additional_contacts
      @back_url = support_case_path(@current_case, anchor: "school-details")
      @additional_contacts = @current_case.case_additional_contacts.order(:created_at)
    end

    def get_emails_of_contacts
      @emails = @current_case.case_additional_contacts.pluck(:email)
      @emails << @current_case.email
    end

    def case_additional_contact_form_params
      params.require(:case_additional_contacts_form).permit(:first_name, :last_name, :email, :phone_number, :extension_number, :support_case_id, :organisation_id, role: []).tap do |p|
        p[:role].reject!(&:blank?)
      end
    end
  end
end
