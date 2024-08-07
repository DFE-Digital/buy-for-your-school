module Support
  class Cases::AdditionalContactsController < Cases::ApplicationController
    before_action :set_current_case, only: %i[create update edit new]
    before_action :set_additional_contact, only: %i[edit update destroy]
    before_action :set_additional_contacts, only: %i[index]
    before_action :get_emails_of_contacts, only: %i[create update]

    def index; end

    def new
      @additional_contact = @current_case&.case_additional_contacts&.build
    end

    def create
      @current_case = Support::Case.find(additional_contact_params[:support_case_id]) if @current_case.blank?
      @additional_contact = Support::CaseAdditionalContact.build(additional_contact_params)

      if validation.success? && !@emails.include?(additional_contact_params[:email])
        @additional_contact.save!
        redirect_to support_case_additional_contacts_path(case_id: @current_case.id), notice: I18n.t("support.case_contact_details.flash.success")
      else
        flash.now[:notice] = I18n.t("support.case_contact_details.flash.already_a_contact") if @emails.include?(additional_contact_params[:email])
        render :new
      end
    end

    def edit
      @current_case = Support::Case.find(@additional_contact.support_case_id)
    end

    def update
      @emails.delete(@additional_contact.email)
      if validation.success? && !@emails.include?(additional_contact_params[:email])
        @additional_contact.update!(additional_contact_params)
        redirect_to support_case_additional_contacts_path(case_id: @current_case.id), notice: I18n.t("support.case.label.non_participating_schools.success.message") if @additional_contact.update(additional_contact_params)

      else
        flash.now[:notice] = I18n.t("support.case_contact_details.flash.already_a_contact") if @emails.include?(additional_contact_params[:email])
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
      CaseAdditionalContactFormSchema.new.call(**additional_contact_params)
    end

    def set_additional_contact
      @additional_contact = Support::CaseAdditionalContact.find(params[:id])
    end

    def set_additional_contacts
      @additional_contacts = @current_case.case_additional_contacts
    end

    def get_emails_of_contacts
      @emails = @current_case.case_additional_contacts.pluck(:email)
      @emails << @current_case.email
    end

    def additional_contact_params
      params.require(:support_case_additional_contact).permit(:first_name, :last_name, :email, :phone_number, :extension_number, :support_case_id, :organisation_id, role: []).tap do |p|
        p[:role].reject!(&:blank?)
      end
    end
  end
end
