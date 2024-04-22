require "rails_helper"

describe "Agent can download frameworks register csv" do
  before do
    agent_is_signed_in(roles: %w[procops framework_evaluator])
  end

  it "provides a framework register CSV download" do
    get "/frameworks.csv"
    expect(response.headers["Content-Type"]).to eq "text/csv"
    expect(response.headers["Content-Disposition"]).to match(/^attachment/)
    expect(response.headers["Content-Disposition"]).to match(/filename="frameworks_data.csv"/)
  end
end
