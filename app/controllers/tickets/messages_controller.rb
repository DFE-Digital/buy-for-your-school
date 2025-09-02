class Tickets::MessagesController < ApplicationController
  include SupportAgents

  before_action :find_email

  def update
    @email.update(
      subject: form_params[:subject],
      to_recipients: form_params[:to_recipients].present? ? JSON.parse(form_params[:to_recipients]) : [],
      cc_recipients: form_params[:cc_recipients].present? ? JSON.parse(form_params[:cc_recipients]) : [],
      bcc_recipients: form_params[:bcc_recipients].present? ? JSON.parse(form_params[:bcc_recipients]) : [],
      body: form_params[:html_content],
    )
  end

  def destroy
    @email.transaction do
      @email.attachments.destroy_all
      @email.destroy!
    end
    redirect_to url_for(params[:redirect_back])
  end

  def list_attachments
    attachments = @email.attachments.map do |attachment|
      {
        file_id: attachment.id,
        name: attachment.file_name,
      }
    end
    render status: :ok, json: attachments.to_json
  end

  def add_attachment
    file_attachment_uploader = @email.file_attachment_uploader(file: params[:file])
    if file_attachment_uploader.valid?
      persisted_file = file_attachment_uploader.save!
      render status: :ok, json: { file_id: persisted_file.id, name: persisted_file.file_name }.to_json
    else
      params[:file].tempfile.delete
      render status: :unprocessable_entity, json: file_attachment_uploader.errors.to_json
    end
  end

  def remove_attachment
    attachment = @email.attachments.find(params[:file_id])
    attachment.destroy!
    head :ok
  end

private

  def form_params
    params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id)
  end

  def find_email
    @email = Email.find(params[:message_id])
  end

  def authorize_agent_scope = :access_individual_cases?
end
