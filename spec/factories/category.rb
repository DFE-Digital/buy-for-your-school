FactoryBot.define do
  factory :category do
    title { "category title" }
    description { "category description" }
    sequence(:contentful_id) { |n| n }
    liquid_template { "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}" }
    slug { "slug" }

    trait :catering do
      title { "Catering" }
      description { "Kitchen staff, equipment, servicing and supplies" }
      slug { "catering" }
    end

    trait :mfd do
      title { "Multi-functional devices" }
      description { "MFDs combine scanners, printers, fax and photocopiers" }
      slug { "mfd" }
    end
  end
end
