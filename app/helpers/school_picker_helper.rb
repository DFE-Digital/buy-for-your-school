module SchoolPickerHelper
  def school_picker_la_filter_options(organisations)
    CheckboxOption
      .from(
        organisations.map(&:local_authority).uniq.sort_by { |k| k["name"] },
        id_field: "la_code",
        title_field: "name",
      )
  end

  def school_picker_status_filter_options(organisations)
    desired_filter_order = %w[opened closing opening closed]
    order_map = desired_filter_order.each_with_index.to_h
    statuses = organisations.pluck(:status).uniq.sort_by { |value| order_map[value] }
    CheckboxOption.from(I18nOption.from("components.school_picker.statuses.%%key%%", statuses))
  end

  def school_picker_phase_filter_options(organisations)
    phases = organisations.pluck(:phase).uniq.map { |phase| %w[middle_primary middle_secondary].include?(phase) ? "middle" : phase }.uniq.sort
    CheckboxOption.from(I18nOption.from("components.school_picker.phases.%%key%%", phases))
  end

  def show_school_picker_status_filters?(organisations)
    organisations.pluck(:status).uniq.length > 1
  end

  def show_school_picker_phase_filters?(organisations)
    organisations.pluck(:phase).uniq.length > 1
  end

  def show_school_picker_la_filters?(organisations)
    organisations.map(&:local_authority).uniq.length > 1
  end

  def show_school_picker_filters?(organisations)
    show_school_picker_la_filters?(organisations) || show_school_picker_phase_filters?(organisations)
  end

  def organisation_should_display?(org, filtered_orgs)
    filtered_orgs.any? { |o| o.urn == org.urn }
  end
end
