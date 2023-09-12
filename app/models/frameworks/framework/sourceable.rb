module Frameworks::Framework::Sourceable
  extend ActiveSupport::Concern

  included do
    enum source: {
      spreadsheet_import: 0,
    }
  end
end
