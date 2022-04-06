FactoryBot.define do
  factory :support_procurement, class: "Support::Procurement" do
    required_agreement_type { :ongoing }
    route_to_market { :bespoke }
    reason_for_route_to_market { :school_pref }
    started_at { "2020-12-02" }
    ended_at { "2021-12-01" }
    stage { :need }

    association :framework, factory: :support_framework

    trait :blank do
      required_agreement_type { nil }
      route_to_market { nil }
      reason_for_route_to_market { nil }
      framework { nil }
      started_at { nil }
      ended_at { nil }
      stage { nil }
    end
  end
end
