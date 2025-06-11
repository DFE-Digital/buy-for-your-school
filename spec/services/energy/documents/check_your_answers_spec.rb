require "rails_helper"

RSpec.describe Energy::Documents::CheckYourAnswers do
  it_behaves_like "with attachable PDF", "EFS Summary"
end
