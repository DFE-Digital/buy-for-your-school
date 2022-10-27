class AddFrameworkRequestToUserJourney < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_journeys, :framework_request, foreign_key: true, type: :uuid
  end
end
