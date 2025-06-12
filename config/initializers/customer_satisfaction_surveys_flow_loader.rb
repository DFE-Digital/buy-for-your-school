SURVEY_FLOWS = YAML.load_file(
  Rails.root.join("config/customer_satisfaction_surveys_flow.yml"),
).with_indifferent_access
