describe UserJourneyStep, type: :model do
  xit { is_expected.to validate_uniqueness_of(:step_description).scoped_to(:user_journey_id) }
end
