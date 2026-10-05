module Energy
  class RegisterYourInterest < ApplicationRecord
    self.table_name = "energy_register_your_interests"
    enum :status, { in_progress: 0, submitted: 1 }

    attr_accessor :step

    validates :name, presence: true, if: -> { step == "name" }
    validates :email, presence: true, email_address: { format: true }, if: -> { step == "email" }
    validates :phone_number, presence: true, if: -> { step == "phone" }
    validates :mat_uid, presence: true, if: -> { step == "mat" }
    validates :switch_gas, inclusion: { in: [true, false] }, if: -> { step == "gas" }
    validates :switch_electricity, inclusion: { in: [true, false] }, if: -> { step == "electricity" }
    validates :name, :email, :phone_number, :mat_uid, :mat_name, :ukprn, presence: true, if: -> { step == "check-answers" }
    validates :switch_gas, :switch_electricity, inclusion: { in: [true, false] }, if: -> { step == "check-answers" }
  end
end
