module CaseRequest::CaseCreatable
  extend ActiveSupport::Concern

  def create_case
    transaction do
      attrs = attributes.symbolize_keys.merge(participating_schools: school_urns.map { |urn| Support::Organisation.find_by(urn:) }, creator: created_by)
      kase = Support::CreateCase.new(attrs).call
      submit_uploads(kase.id) if engagement_case_uploads.present?
      Support::CreateInteraction.new(kase.id, "create_case", created_by.id, { body: "Case created", additional_data: attrs.slice(:source, :category).compact }).call
      update!(submitted: true, support_case: kase)
      kase
    end
  end

private

  def submit_uploads(support_case_id)
    engagement_case_uploads.update_all(upload_status: :submitted, support_case_id:)

    engagement_case_uploads.each do |upload|
      Support::CaseAttachment.create(
        attachable: upload,
        support_case_id:,
        custom_name: upload.file_name,
        description: "User uploaded attachment",
        created_at: upload.created_at,
        updated_at: upload.updated_at,
      )
    end
  end
end
