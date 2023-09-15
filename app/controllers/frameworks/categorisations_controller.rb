class Frameworks::CategorisationsController < Frameworks::ApplicationController
  def edit
    @framework = Frameworks::Framework.find(params[:framework_id])
  end

  def update
    @framework = Frameworks::Framework.find(params[:framework_id])

    @framework.update!(category_params)

    redirect_to @framework
  end

private

  def category_params
    params.require(:frameworks_framework).permit(support_category_ids: [])
  end
end
