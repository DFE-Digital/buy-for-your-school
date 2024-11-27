module Support
  module Management
    class EmailTemplateForm
      include ActiveModel::Model

      validates :group_id, presence: true
      validates :title, presence: true
      validates :description, presence: true
      validates :body, presence: true
      validate :files_safe

      attr_accessor(
        :id,
        :group_id,
        :subgroup_id,
        :stage,
        :title,
        :description,
        :subject,
        :body,
        :file_attachments,
        :blob_attachments,
        :created_by,
        :updated_by,
        :agent,
      )

      def self.from_email_template(id)
        email_template = Support::EmailTemplate.find(id)
        if email_template.group.is_top_level?
          group_id = email_template.group.id
        else
          group_id = email_template.group.parent_id
          subgroup_id = email_template.group.id
        end

        new(
          id:, group_id:, subgroup_id:,
          stage: email_template.stage,
          title: email_template.title,
          description: email_template.description,
          subject: email_template.subject,
          body: email_template.body,
          created_by: email_template.created_by,
          updated_by: email_template.updated_by
        )
      end

      def initialize(attributes = {})
        super
        @group = Support::EmailTemplateGroup.find(@group_id) if @group_id.present?
        @subgroup = Support::EmailTemplateGroup.find(@subgroup_id) if @subgroup_id.present?
        @created_by = @agent if @agent.present? && @id.blank?
        @updated_by = @agent if @agent.present?
        @files = @file_attachments
        @file_attachments = @files&.map { |file| Support::EmailTemplateAttachment.new(file:) } || []
        @blob_attachments = resolve_blob_attachments(@blob_attachments)
      end

      def files_safe
        return if @files.blank?

        results = @files.map { |file| Support::VirusScanner.uploaded_file_safe?(file) }
        errors.add(:file_attachments, I18n.t("support.management.email_templates.common.unsafe_attachments")) unless results.all?
      end

      def save!
        email_template.update!(email_template_attributes)
      end

      def group_options
        Support::EmailTemplateGroup.top_level.map { |group| [group.title, group.id] }
      end

      def subgroup_options
        return [] if @group.blank?

        @group.sub_groups.map { |subgroup| [subgroup.title, subgroup.id] }
      end

      def stage_options
        Support::EmailTemplate.stages.map { |stage| ["#{I18n.t('support.management.email_templates.common.stage')} #{stage}", stage] }
      end

      def email_template
        @email_template ||= @id ? Support::EmailTemplate.find(@id) : Support::EmailTemplate.new
      end

    private

      def email_template_attributes
        instance_values.slice(*Support::EmailTemplate.attribute_names, "created_by", "updated_by")
          .merge(
            group: @subgroup.presence || @group,
            subject: @subject.presence,
            attachments: @blob_attachments + @file_attachments,
          )
          .except("created_at", "updated_at")
          .compact
      end

      def resolve_blob_attachments(blob_attachments)
        return [] if blob_attachments.blank?

        JSON.parse(blob_attachments).map do |attrs|
          type = attrs["type"]
          id = attrs["file_id"]
          raise "Unexpected attachment type #{type}" unless type == "Support::EmailTemplateAttachment"

          Support::EmailTemplateAttachment.find(id)
        end
      end
    end
  end
end
