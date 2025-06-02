module Energy
  class AuthorisationController < ApplicationController
    before_action :validate_school
    before_action :check_active_onboarding_case
    before_action { @back_url = energy_school_selection_path }

    def show; end

    def update
      return unless params[:type] == "single"

      @onboarding_case_organisation = create_onboarding_case

      draft_and_send_onboarding_email_to_school
      redirect_to energy_case_switch_energy_path(case_id: @onboarding_case_organisation.energy_onboarding_case_id)
    end

  private

    def existing_onboarding_organisations
      Energy::OnboardingCaseOrganisation.where(onboardable: @support_organisation)
    end

    def create_onboarding_case
      Energy::CaseCreatable.create_case(current_user, @support_organisation)
    end

    def check_active_onboarding_case
      if existing_onboarding_organisations.any?
        energy_case_ids = existing_onboarding_organisations.pluck(:energy_onboarding_case_id)
        energy_cases = Energy::OnboardingCase.where(id: energy_case_ids)

        if energy_cases.any?
          support_case_ids = energy_cases.pluck(:support_case_id)
          support_case = Support::Case.where(
            id: support_case_ids,
            email: current_user.email,
          ).where.not(state: %w[closed resolved])

          if support_case.count > 1
            email_to = ENV["MS_GRAPH_SHARED_MAILBOX_ADDRESS"]
            email_subject = I18n.t("energy.authorisation.alerts.email_subject", org_name: @support_organisation.name)
            email_body = render_to_string(partial: "energy/authorisation/email_body")
            click_here = I18n.t("energy.authorisation.alerts.click_here")
            email_link = ActionController::Base.helpers.mail_to(email_to, click_here, subject: email_subject, body: email_body, class: "govuk-link")
            notice_message = "#{I18n.t('energy.authorisation.alerts.multiple_cases')}, #{email_link}".html_safe
            redirect_to energy_school_selection_path, notice: notice_message
          elsif support_case.count == 1
            active_case = Energy::OnboardingCase.find_by(support_case_id: support_case.first.id)
            active_onboarding_case = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: active_case.id)

            if active_onboarding_case.switching_energy_type.nil?
              redirect_to energy_case_switch_energy_path(case_id: active_onboarding_case.energy_onboarding_case_id)
            else
              redirect_to energy_case_tasks_path(case_id: active_onboarding_case.energy_onboarding_case_id)
            end
          end
        end
      end
    end

    def validate_school
      @support_organisation, valid_school_urns = support_organisation_and_valid_urns
      @school_list = Support::Organisation.where(trust_code: params[:id]) if params[:type] == "mat"

      redirect_to energy_school_selection_path unless @support_organisation && valid_school_urns.include?(params[:id])
    end

    def support_organisation_and_valid_urns
      if params[:type] == "mat"
        [
          Support::EstablishmentGroup.find_by(uid: params[:id]),
          current_user.orgs.pluck("uid"),
        ]
      else
        [
          Support::Organisation.find_by(urn: params[:id]),
          current_user.orgs.pluck("urn"),
        ]
      end
    end

    def draft_and_send_onboarding_email_to_school
      Energy::Emails::OnboardingFormStartedMailer.new(
        onboarding_case_organisation: @onboarding_case_organisation,
        to_recipients: current_user.email,
        default_email_template:,
        onboarding_case_link:,
      ).call
    end

    def default_email_template
      render_to_string(partial: "energy/authorisation/onboarding_email_template")
    end

    def onboarding_case_link
      energy_case_tasks_url(case_id: @onboarding_case_organisation.energy_onboarding_case_id, host: request.host)
    end
  end
end
