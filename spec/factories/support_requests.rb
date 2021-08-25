FactoryBot.define do
  factory :support_request do
    message { "Support request message from a School Buying Professional" }

    association :user, factory: :user

    # trait :with_specification_ids do
    #   # association { create(:journey) }
    # end

    # trait :with_category_id do
    #   # association { create(:create) }
    # end
  end
end
