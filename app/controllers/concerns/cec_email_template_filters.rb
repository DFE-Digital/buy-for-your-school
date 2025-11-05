module CecEmailTemplateFilters
  extend ActiveSupport::Concern

  included do
    before_action :cec_template_group
  end

private

  def filter_params
    filters = params.fetch(:email_template_filters, {}).permit(:group_id, :remove_group, :remove_subgroup, :remove_stage, subgroup_ids: [], stages: [])

    if (current_agent&.roles & %w[cec cec_admin]).any? && params[:email_template_filters].blank?
      filters[:group_id] = @cec_group&.id
      filters[:subgroup_ids] = [@dfe_subgroup&.id]
    end

    filters
  end

  def cec_template_group
    @cec_group = Support::EmailTemplateGroup.find_by(title: "CEC")
    if @cec_group.present?
      @dfe_subgroup = Support::EmailTemplateGroup.find_by(title: "DfE Energy for Schools service", parent_id: @cec_group.id)
    end
  end
end
