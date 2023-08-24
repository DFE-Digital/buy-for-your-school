class Frameworks::Framework < ApplicationRecord
  include FafImportable
  include StatusChangeable

  belongs_to :provider
end
