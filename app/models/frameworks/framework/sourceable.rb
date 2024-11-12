module Frameworks::Framework::Sourceable
  extend ActiveSupport::Concern

  included do
    enum :source, {
      spreadsheet_import: 0,
      register: 1,
      faf_import: 2,
    }
  end
end
