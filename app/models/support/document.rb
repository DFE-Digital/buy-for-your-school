module Support
  class Document < ApplicationRecord

    belongs_to :documentable, polymorphic: true, optional: true

  end
end
