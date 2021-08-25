# TODO: replace this with an ActiveRecord model
# :nocov:
module Support
  class CaseWorkerAccount
    def self.all
      [find_by]
    end

    def self.find_by(_ignore = nil)
      OpenStruct.new(
        id: 1,
        name: 'Dracula',
        email_address: 'fast@and.furious',
        job_role: 'King',
        created_at: 3.minutes.ago,
        updated_at: 2.minutes.ago
      )
    end
  end
end
# :nocov: