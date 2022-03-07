# frozen_string_literal: true

module Support
  class SearchCases
    def search(search_params)
      results = Case.includes(%i[agent category organisation]).where(nil)

      return results if search_params.nil?

      results
    end

  private

    def results
      Case.includes(%i[agent category organisation]).where("case_ref ILIKE ? or orag")
    end
  end
end
