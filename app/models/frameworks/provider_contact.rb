class Frameworks::ProviderContact < ApplicationRecord
  include Frameworks::ActivityLoggable
  include ActivityLogPresentable
  include Presentable
  include Filterable
  include Sortable

  belongs_to :provider
  has_many :frameworks

  validates :name, presence: true
  validates :email, presence: true
  validates :provider_id, presence: true
end
