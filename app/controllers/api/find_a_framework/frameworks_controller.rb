# frozen_string_literal: true

class Api::FindAFramework::FrameworksController < Api::BaseController
  def changed
    added_frameworks = []
    framework_params.each do |framework|
      f = Support::Framework.upsert(
        {
          name: framework[:title],
          supplier: framework[:provider][:initials],
          category: framework[:cat][:title],
          expires_at: framework[:expiry],
        },
        unique_by: %i[name supplier],
        returning: %w[name supplier],
      )
      added_frameworks << f.first
    end

    render json: { status: "OK" }, status: :ok
    Rollbar.info("Processed webhook event for FaF framework", added_frameworks)
  end

private

  def framework_params
    params.permit(_json: [:title, { provider: [:initials] }, { cat: [:title] }, :expiry])[:_json]
  end
end
