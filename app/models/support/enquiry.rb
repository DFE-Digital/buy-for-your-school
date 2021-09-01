module Support
  class Enquiry < ApplicationRecord
    include Support::Documentable

    belongs_to :case, class_name: "Support::Case", optional: true

  end
end
