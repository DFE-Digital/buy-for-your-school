class Frameworks::FrameworkCategory < ApplicationRecord
  belongs_to :support_category, class_name: "Support::Category"
  belongs_to :framework
end
