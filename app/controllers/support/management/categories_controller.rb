module Support
  class Management::CategoriesController < ::Support::Management::BaseController
    def index
      @top_level_categories = Support::Category.top_level.includes(sub_categories: [:cases])
      @towers = Support::Tower.unique_towers
    end

    def update
      @category = Support::Category.find(params[:id])
      @category.update!(category_form_params)

      Rollbar.info("CMS Management: Category details have been updated",
                   admin_user_id: current_user.id, category_id: @category.id)

      redirect_to support_management_categories_path
    end

  private

    def authorize_agent_scope = [super, :access_proc_ops_portal?]

    def category_form_params
      params.require(:category).permit(:support_tower_id, :parent_id)
    end
  end
end
