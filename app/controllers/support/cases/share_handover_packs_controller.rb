module Support
  class Cases::ShareHandoverPacksController < Cases::ApplicationController
    before_action :set_current_case
    before_action :set_email_addresses
    before_action :set_documents
    before_action :set_template
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }

    def edit
      @draft = Email::Draft.new(
        default_content: default_template,
        default_subject:,
        template_id: @template_id,
        ticket: current_case.to_model,
        to_recipients: @to_recipients,
      ).save_draft!

      @email_id = @draft.id
      @share_handover = Email::Draft.find(@email_id)
      parse_template
    end

    def update
      @share_handover = Email::Draft.find(params[:id])
      @share_handover.attributes = form_params
      parse_template
      if @share_handover.valid?(:new_message)
        @share_handover.save_draft!
        @share_handover.deliver_as_new_message

        @current_case.update!(has_shared_handover_pack: true)

        log_share_handover_packs

        redirect_to @back_url
      else
        render :edit
      end
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def set_email_addresses
      @evaluators = @current_case.contract_recipients.all
      @email_addresses = @evaluators.map(&:email)
      @to_recipients = @email_addresses.to_json
    end

    def set_documents
      @documents = @current_case.upload_contract_handovers
    end

    def form_params
      params.require(:share_handover).permit(:html_content)
    end

    def draft_email_params
      params.require(:share_handover).permit(:id)
    end

    def default_subject = I18n.t("support.cases.share_handover_pack.default_subject", current_ref: current_case.ref)

    def default_template = render_to_string(partial: "support/cases/share_handover_packs/form_template")

    def set_template
      template = Support::EmailTemplate.find_by(title: "Contract handover email invitation")
      @template_id = template.id if template
      @unique_link = my_procurements_verify_unique_link_path(@current_case, host: request.host)
    end

    def parse_template
      @share_handover.html_content = Support::EmailEvaluatorsVariableParser.new(@current_case, @share_handover, @unique_link).parse_template
    end

    def log_share_handover_packs
      data = { support_case_id: @current_case.id, email_id: params[:id], to_recipients: @to_recipients }
      Support::EvaluationJourneyTracking.new(:share_handover_packs, data).call
    end
  end
end
