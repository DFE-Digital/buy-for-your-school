module Support
  module Management
    class EmailTemplateFilterForm
      include ActiveModel::Model

      attr_accessor(
        :group_id,
        :subgroup_ids,
        :stages,
        :remove_group,
        :remove_subgroup,
        :remove_stage,
      )

      def initialize(attributes = {})
        super
        clean_fields
        remove_filters
        @group = Support::EmailTemplateGroup.find(@group_id) if @group_id.present?
        @subgroup_ids = [Support::Emails::Templates::Filter.all_none_values[:all]] if subgroup_ids.blank?
        @stages = [Support::Emails::Templates::Filter.all_none_values[:all]] if stages.blank?
      end

      def group_options
        Support::EmailTemplateGroup.top_level.map { |group| [group.title, group.id] }
      end

      def subgroup_options
        return [] if @group.blank?

        other_options = [
          OpenStruct.new(id: Support::Emails::Templates::Filter.all_none_values[:all], title: I18n.t("support.management.email_templates.index.template_manager.filters.all_subgroups"), exclusive: true),
          OpenStruct.new(id: Support::Emails::Templates::Filter.all_none_values[:none], title: I18n.t("support.management.email_templates.index.template_manager.filters.no_subgroups"), exclusive: false),
        ]
        other_options + @group.sub_groups.map { |subgroup| OpenStruct.new(id: subgroup.id, title: subgroup.title, exclusive: false) }
      end

      def stage_options
        other_options = [
          OpenStruct.new(id: Support::Emails::Templates::Filter.all_none_values[:all], title: I18n.t("support.management.email_templates.index.template_manager.filters.all_stages"), exclusive: true),
          OpenStruct.new(id: Support::Emails::Templates::Filter.all_none_values[:none], title: I18n.t("support.management.email_templates.index.template_manager.filters.no_stage"), exclusive: false),
        ]
        other_options + Support::EmailTemplate.stages.map { |stage| OpenStruct.new(id: stage.to_s, title: "#{I18n.t('support.management.email_templates.common.stage')} #{stage}", exclusive: false) }
      end

      def has_subgroups?
        @group.present? && !@group.sub_groups.empty?
      end

      def tags
        tags = []
        tags.push(OpenStruct.new(id: @group.id, title: @group.title, type: :group)) if @group.present?
        subgroup_options.select { |subgroup| @subgroup_ids.include?(subgroup.id) unless subgroup.id == Support::Emails::Templates::Filter.all_none_values[:all] }.each do |subgroup|
          tags.push(OpenStruct.new(id: subgroup.id, title: subgroup.title, type: :subgroup))
        end
        stage_options.select { |stage| @stages.include?(stage.id) unless stage.id == Support::Emails::Templates::Filter.all_none_values[:all] }.each do |stage|
          tags.push(OpenStruct.new(id: stage.id, title: stage.title, type: :stage))
        end
        tags
      end

      def results
        Support::Emails::Templates::Filter.new.by_groups(@group_id, subgroups: @subgroup_ids).by_stages(@stages).results
      end

    private

      def clean_fields
        @subgroup_ids = @subgroup_ids&.reject(&:blank?)
        @stages = @stages&.reject(&:blank?)
      end

      def remove_filters
        @group_id = nil if @remove_group.present?
        @subgroup_ids&.delete(@remove_subgroup)
        @stages&.delete(@remove_stage)
      end
    end
  end
end
