module Support
  class EmailTemplatePresenter < BasePresenter
    def initialize(obj, parser)
      super(obj)
      @parser = parser
    end

    def groups
      group.hierarchy
    end

    def stage
      return unless super

      "#{I18n.t('support.management.email_templates.common.stage')} #{super}"
    end

    def body_parsed = @parser.parse(body)
  end
end
