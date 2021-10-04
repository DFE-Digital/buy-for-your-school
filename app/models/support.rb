#
# Temporary namespace to encapsulate the case management application
#
module Support
  #
  # Ensure `Supported` data is not conflated with `Specify`
  #
  def self.table_name_prefix
    "support_"
  end
end
