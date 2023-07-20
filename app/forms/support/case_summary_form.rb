module Support
  class CaseSummaryForm
    extend Dry::Initializer
    include Concerns::ValidatableForm
    include Concerns::RequestDetailsFormFields

    attr_accessor :agent_id

    option :source, optional: true
    option :support_level, optional: true
    option :value, optional: true
    option :procurement_stage_id, optional: true

    def self.from_case(support_case)
      new(
        category_id: support_case.category_id,
        query_id: support_case.query_id,
        other_category: support_case.other_category,
        other_query: support_case.other_query,
        request_text: support_case.request_text,
        request_type: support_case.category_id.present?,
        source: support_case.source,
        support_level: support_case.support_level,
        value: support_case.value,
        procurement_stage_id: support_case.procurement_stage_id,
      )
    end

    def source_options
      Support::Case.sources.keys
        .map { |key| OpenStruct.new(title: I18n.t("support.case.label.source.#{key.downcase}"), id: key) }
    end

    def procurement_stage
      @procurement_stage ||= Support::ProcurementStagePresenter.new(Support::ProcurementStage.find(procurement_stage_id)) if procurement_stage_id.present?
    end

    def procurement_stage_options
      Support::ProcurementStage.all.map { |stage| OpenStruct.new(title: stage.title, id: stage.id) }
    end

    def update_case_summary_details(kase:, agent_id:)
      CaseManagement::UpdateCaseSummaryDetails.new.call(
        case_id: kase.id,
        agent_id:,
        category_id:,
        query_id:,
        other_category:,
        other_query:,
        request_text:,
        source:,
        support_level:,
        value:,
        procurement_stage_id:,
      )
    end
  end
end
