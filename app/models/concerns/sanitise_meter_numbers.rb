module SanitiseMeterNumbers
  extend ActiveSupport::Concern

private

  # Remove spaces, dashes, brackets
  # The \D removes any non-digit characters but won't catch non-breaking spaces
  # hence the explicit \u00A0
  def sanitise_meter_number(number)
    number.gsub(/[\s\-()\D]/, "").delete("\u00A0")
  end
end
