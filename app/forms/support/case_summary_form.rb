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
  end
end
