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
        [I18n.t("support.case.label.key_action_date"), "next_key_date"],
        [I18n.t("support.case.label.contract_start_date"), "contract_start_date"],
      ]
    end

    def eando_available_sort_options
      [
        [I18n.t("support.case.label.case"), "ref"],
        [I18n.t("support.case.label.level"), "support_level"],
        [I18n.t("support.case.label.organisation"), "organisation_name"],
        [I18n.t("support.case.label.category"), "subcategory"],
        [I18n.t("support.case.label.status"), "state"],
        [I18n.t("support.case.label.updated"), "last_updated"],
      ]
    end

    def cec_available_sort_options
      [
        [I18n.t("support.case.label.case"), "ref"],
        [I18n.t("support.case.label.level"), "support_level"],
        [I18n.t("support.case.label.organisation"), "organisation_name"],
        [I18n.t("support.case.label.status"), "state"],
        [I18n.t("support.case.label.updated"), "last_updated"],
      ]
    end

    def available_sort_orders
      I18nOption.from("support.case.label.%%key%%", %w[ascending descending])
    end
  end
end
