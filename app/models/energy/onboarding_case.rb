class Energy::OnboardingCase < ApplicationRecord
  belongs_to :support_case, class_name: "Support::Case"
end
