module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"
  end
end
