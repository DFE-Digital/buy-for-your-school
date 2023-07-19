module Support
  class Management::CategoriesController < ::Support::Management::BaseController
    def index
      @top_level_categories = Support::Category.top_level.includes(sub_categories: [:cases])
      @towers = Support::Tower.unique_towers
    end

  private

    def authorize_agent_scope = [super, :access_proc_ops_portal?]
  end
end
