class NewContract < Contract
  has_one :support_case, class_name: "Support::Case"
end
