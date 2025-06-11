require "rails_helper"

RSpec.describe Energy::Documents::CheckYourAnswers do
  it_behaves_like "attachable PDF", "EFS Summary"
end
