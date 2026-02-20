module SolutionHelper
  def solution_cta(solution)
    solution.call_to_action.presence || t("solutions.show.cta", title: solution.title)
  end
end
