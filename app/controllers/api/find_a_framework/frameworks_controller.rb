# frozen_string_literal: true

class Api::FindAFramework::FrameworksController < Api::FindAFramework::BaseController
  def changed
    framework = Support::Framework.upsert(
      {
        name: framework_params[:title],
        supplier: framework_params[:provider][:initials],
        category: framework_params[:cat][:title],
        expires_at: framework_params[:expiry],
      },
      unique_by: %i[name supplier],
      returning: %w[name supplier],
    )

    if framework.first
      render json: { status: "OK" }, status: :ok
      Rollbar.info("Processed webhook event for FaF framework", **framework.first)
    end
  end

private

  def framework_params
    params.require(:framework).permit(:title, { provider: [:initials] }, { cat: [:title] }, :expiry)
  end
end
