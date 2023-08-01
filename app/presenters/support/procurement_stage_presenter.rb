module Support
  class ProcurementStagePresenter < BasePresenter
    def detailed_title
      "#{stage_label} - #{title}"
    end

    def detailed_title_short
      "#{stage_indicator} - #{title}"
    end

    def stage_indicator
      "S#{stage}"
    end

    def stage_label
      "Stage #{stage}"
    end
  end
end
