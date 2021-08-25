# TODO: replace this with an ActiveRecord model
# :nocov:
module Support
  class CMContact
    def self.all
      [find_by]
    end

    def self.find_by(_ignore = nil)
      OpenStruct.new(
        id: 1,
        first_name: 'John',
        last_name: 'Wick',
        email_address: 'john@wick.com',
        phone_number: '+44 777888999',
        digital_account_id: 1,
        created_at: 3.minutes.ago,
        updated_at: 2.minutes.ago
      )
    end
  end
end
# :nocov: