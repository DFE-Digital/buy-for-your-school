FactoryBot.define do
  factory :support_procurement, class: "Support::Procurement" do
    required_agreement_type { :ongoing }
    route_to_market { :bespoke }
    reason_for_route_to_market { :school_pref }
    framework_name { "Framework" }
    started_at { "2020-12-02" }
    ended_at { "2021-12-01" }
    stage { :need }
  end
end
