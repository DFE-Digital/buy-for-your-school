module Support
  class CaseSearchPresenter < BasePresenter
    def organisation_name
      super || email || "n/a"
    end
  end
end
