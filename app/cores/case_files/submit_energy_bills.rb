module CaseFiles
  class SubmitEnergyBills
    def call(framework_request_id:, support_case_id:)
      energy_bills = EnergyBill.where(framework_request_id:)

      energy_bills.update_all(submission_status: :submitted, support_case_id:)

      energy_bills.each do |energy_bill|
        Support::CaseAttachment.create(
          attachable: energy_bill,
          support_case_id:,
          custom_name: energy_bill.file_name,
          description: "User uploaded energy bill",
          created_at: energy_bill.created_at,
          updated_at: energy_bill.updated_at,
        )
      end
    end
  end
end
