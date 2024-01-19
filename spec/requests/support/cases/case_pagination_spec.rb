require "rails_helper"

describe "Pagination of cases" do
  let(:agent) { create(:support_agent) }

  before { agent_is_signed_in(agent:) }

  {
    "#my-cases" => "my_cases_page",
    "#all-cases" => "cases_page",
    "#new-cases" => "new_cases_page",
  }.each do |tab, param|
    describe "on #{tab} tab" do
      context "when there is more than 10 cases (15)" do
        before { create_list(:support_case, 15, agent:) } # all cases are new and assigned to the agent

        let(:response_body) { Nokogiri::HTML(response.body).css(tab) }

        it "page 1 has the first 10 cases on it" do
          get "/support/cases#{tab}"
          expect(response_body.text).to include("Showing 1 to 10 of 15 results")
        end

        it "page 2 has the remaining 4 cases" do
          get "/support/cases?#{param}=2#{tab}"
          expect(response_body.text).to include("Showing 11 to 15 of 15 results")
        end
      end
    end
  end
end
