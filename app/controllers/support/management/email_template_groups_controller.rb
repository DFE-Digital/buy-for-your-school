module Support
  module Management
    class EmailTemplateGroupsController < BaseController
      def subgroups
        group = Support::EmailTemplateGroup.find(params[:group_id])
        render status: :ok, json: group.sub_groups.to_json
      end

    private

      def authorize_agent_scope = [super, :access_proc_ops_portal?]
    end
  end
end
