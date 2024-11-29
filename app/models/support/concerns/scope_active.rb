module Support::Concerns::ScopeActive
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(archived: false) }
  end
end
