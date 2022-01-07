module Support
  class EmailPresenter < ::Support::BasePresenter
    # @return [String]
    def case_reference
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).ref
    end

    def case_org_name
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).org_name
    end

    def sent_by_email
      return nil if sender.nil?

      sender["address"]
    end

    def sent_by_name
      return nil if sender.nil?

      sender["name"]
    end

    def sent_at_formatted
      sent_at.strftime(short_date_time)
    end
  end
end
