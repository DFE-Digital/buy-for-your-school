class Frameworks::Provider < ApplicationRecord
  include Frameworks::ActivityLoggable
  include Sortable
  include Filterable
  include Presentable
end
