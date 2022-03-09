namespace :self_serve do
  desc "Backfill journey names"
  task backfill_journey_names: :environment do
    users_with_unnamed_journeys = User.joins(:journeys).where(journeys: { name: nil }).distinct

    # Get each user that has unnamed journeys
    users_with_unnamed_journeys.each do |user|
      # Sort unnamed journeys by creation date and group by category
      grouped_unnamed_journeys = user.journeys.includes(:category).where(name: nil).order(:created_at).group_by { |j| j.category.title }

      # Give names to all journeys that don't have them
      grouped_unnamed_journeys.each do |category, journeys|
        journeys.each_with_index do |journey, i|
          name = "#{category} specification #{sprintf('%02i', i + 1)}"
          journey.update!(name: name)
        end
      end
    end
  end
end
