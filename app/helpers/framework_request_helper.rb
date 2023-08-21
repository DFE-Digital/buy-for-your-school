module FrameworkRequestHelper
  def school_picker_la_filter_options(organisations)
    CheckboxOption
      .from(
        organisations.map(&:local_authority).uniq.sort_by { |k| k["name"] },
        id_field: "code",
        title_field: "name",
      )
  end

  def school_picker_phase_filter_options(organisations)
    phases = organisations.pluck(:phase).uniq.map { |phase| %w[middle_primary middle_secondary].include?(phase) ? "middle" : phase }.uniq
    CheckboxOption.from(I18nOption.from("faf.school_picker.phases.%%key%%", phases))
  end

  def show_school_picker_phase_filters?(organisations)
    organisations.pluck(:phase).uniq.length > 1
  end

  def show_school_picker_la_filters?(organisations)
    organisations.pluck(:local_authority).uniq.length > 1
  end

  def show_school_picker_filters?(organisations)
    show_school_picker_la_filters?(organisations) || show_school_picker_phase_filters?(organisations)
  end
end
