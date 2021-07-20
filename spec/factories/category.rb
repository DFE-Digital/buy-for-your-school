FactoryBot.define do
  factory :category do
    title { "category title" }
    description { "category description" }
    contentful_id { "12345678" }
    liquid_template { "Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}" }

    trait :catering do
      title { "Catering" }
      description { "Kitchen staff, equipment, servicing and supplies" }
    end

    trait :mfd do
      title { "Multi-functional devices" }
      description { "MFDs combine scanners, printers, fax and photocopiers" }
    end
  end
end
