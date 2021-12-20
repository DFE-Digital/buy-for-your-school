module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
  end
end
