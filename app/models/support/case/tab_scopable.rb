module Support::Case::TabScopable
  extend ActiveSupport::Concern

  class_methods do
    def my_cases_tab(agent, filtering)
      filtering.apply_to(by_agent(agent.id))
    end

    def new_cases_tab(filtering)
      filtering.apply_to(initial)
    end

    def all_cases_tab(filtering)
      filtering.apply_to(where(nil))
    end

    def tower_cases_tab(tower, filtering)
      filtering.apply_to(by_tower(tower.id))
    end

    def triage_cases_tab(filtering)
      filtering.apply_to(triage)
    end
  end
end
