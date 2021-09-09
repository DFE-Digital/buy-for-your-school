module Support
  module Documentable
    extend ActiveSupport::Concern
    included do
      has_many :documents, class_name: "Support::Document", as: :documentable, dependent: :destroy
      accepts_nested_attributes_for :documents, allow_destroy: true, reject_if: :all_blank
    end
  end
end
