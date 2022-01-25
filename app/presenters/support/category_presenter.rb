module Support
  class CategoryPresenter < BasePresenter
    # @return [String]
    def title
      __getobj__.nil? ? I18n.t("support.case_categorisations.label.none") : super
    end
  end
end
