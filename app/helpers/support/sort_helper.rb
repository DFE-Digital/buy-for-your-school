module Support
  module SortHelper
    def available_sort_options
      [
        [I18n.t("support.case.label.flag"), "action"],
        [I18n.t("support.case.label.case"), "ref"],
        [I18n.t("support.case.label.level"), "support_level"],
        [I18n.t("support.case.label.organisation"), "organisation_name"],
        [I18n.t("support.case.label.category"), "subcategory"],
        [I18n.t("support.case.label.status"), "state"],
        [I18n.t("support.case.label.updated"), "last_updated"],
      ]
    end

    def available_sort_orders
      I18nOption.from("support.case.label.%%key%%", %w[ascending descending])
    end
  end
end
