module Support::EstablishmentSearch::Presentable
  extend ActiveSupport::Concern

  def autocomplete_template
    ApplicationController.render(partial: "support/establishment_search/#{source.underscore}/autocomplete_template", locals: autocomplete_template_vars)
  end

private

  def autocomplete_template_vars
    case source
    when "LocalAuthority" then { name:, establishment_type:, code: }
    else { name:, postcode:, establishment_type:, proposed_open_or_closed:, urn:, ukprn: }
    end
  end

  def proposed_open_or_closed
    if organisation_status == "opening"
      "#{I18n.t("support.organisation_statuses.#{organisation_status}")} #{opened_date.strftime('%d-%m-%Y')}"
    elsif organisation_status == "closing"
      "#{I18n.t("support.organisation_statuses.#{organisation_status}")} #{closed_date.strftime('%d-%m-%Y')}"
    end
  end
end
