module Support
  class EmailTemplates
    IDS = {
      basic_template: "ac679471-8bb9-4364-a534-e87f585c46f3",
      what_is_a_framework: "f4696e59-8d89-4ac5-84ca-17293b79c337",
      how_to_approach_suppliers: "6c76ed8c-030e-4c69-8f25-ea0c66091bc5",
      catering_frameworks: "12430165-4ae7-47aa-baa3-d0b3c5440a9b",
      social_value: "bb4e6925-3491-44b8-8747-bdbb31257403",
      user_research: "fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779",
      exit_survey: "134bc268-2c6b-4b74-b6f4-4a58e22d6c8b",
    }.freeze

    def self.label_for(id)
      I18n.t("support.case_email_templates.index.#{EmailTemplates::IDS.key(id) || :unknown}.link_text")
    end
  end
end
