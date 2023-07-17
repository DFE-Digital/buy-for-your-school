module Support
  class ProcurementStagePresenter < BasePresenter
    def title
      "Stage #{stage} - #{super}"
    end
  end
end
