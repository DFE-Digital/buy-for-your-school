module Support
  class CaseSummaryForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :source, optional: true
    option :support_level, optional: true
    option :value, optional: true

    def source_options
      Support::Case.sources.keys
        .map { |key| OpenStruct.new(title: I18n.t("support.case.label.source.#{key.downcase}"), id: key) }
    end

    def update_case_summary_details(kase:, agent_id:)
      CaseManagement::UpdateCaseSummaryDetails.new.call(
        case_id: kase.id,
        agent_id:,
        source:,
        support_level:,
        value:,
      )
    end
  end
end
