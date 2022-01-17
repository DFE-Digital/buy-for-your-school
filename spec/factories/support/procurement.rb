FactoryBot.define do
  factory :support_procurement, class: "Support::Procurement" do
    required_agreement_type { :ongoing }
    route_to_market { :bespoke }
    reason_for_route_to_market { :school_pref }
    framework_name { "Framework" }
    started_at { "2020-12-02" }
    ended_at { "2021-12-01" }
    stage { :need }

    trait :blank do
      required_agreement_type { nil }
      route_to_market { nil }
      reason_for_route_to_market { nil }
      framework_name { nil }
      started_at { nil }
      ended_at { nil }
      stage { nil }
    end
  end
end
