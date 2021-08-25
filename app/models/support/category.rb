# TODO: replace this with an ActiveRecord model
# :nocov:
module Support
  class Category
    def self.all
      [find_by]
    end

    def self.find_by(_ignore = nil)
      OpenStruct.new(
        id: 1,
        name: 'Catering',
        created_at: 3.minutes.ago,
        updated_at: 2.minutes.ago
      )
    end
  end
end
# :nocov: