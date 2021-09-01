module Support
  class Case < ApplicationRecord
    include Support::Documentable

    has_one :enquiry, class_name: "Support::Enquiry"
    belongs_to :category, class_name: "Support::Category"

    enum support_level: { L1: 0, L2: 1, L3: 2, L4: 3, L5: 4 }
    enum state: { initial: 0, open: 1, resolved: 2, pending: 3, closed: 4, pipeline: 5, no_response: 6 }
  end
end
