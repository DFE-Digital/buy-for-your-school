RSpec.describe "Webhook upserts frameworks", type: :request do
  let(:webhook_payload) do
    [
      {
        "title" => "Framework title",
        "provider" => {
          "initials" => "PRVDR",
        },
        "cat" => {
          "title" => "Supplies",
        },
        "expiry" => "2022-12-31",
      },
    ]
  end

  let(:rollbar_info) do
    [
      {
        "name" => "Framework title",
        "supplier" => "PRVDR",
      },
    ]
  end

  before do
    allow_any_instance_of(Api::FindAFramework::BaseController).to receive(:authenticate_api_user!).and_return(true)
  end

  it "creates a new framework" do
    expect(Support::Framework.count).to be_zero
    expect(Rollbar).to receive(:info)
                        .with("Processed webhook event for FaF framework", rollbar_info)
                        .and_call_original

    post "/api/find_a_framework/framework",
         params: webhook_payload,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Support::Framework.first.name).to eql "Framework title"
    expect(Support::Framework.first.supplier).to eql "PRVDR"
  end

  it "updates an existing framework" do
    create(:support_framework, name: "Framework title", supplier: "PRVDR", category: "Old category", expires_at: "2022-01-01")
    expect(Support::Framework.count).to eq 1

    expect(Rollbar).to receive(:info)
                        .with("Processed webhook event for FaF framework", rollbar_info)
                        .and_call_original

    post "/api/find_a_framework/framework",
         params: webhook_payload,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Support::Framework.count).to eq 1
    expect(Support::Framework.first.name).to eql "Framework title"
    expect(Support::Framework.first.supplier).to eql "PRVDR"
    expect(Support::Framework.first.category).to eql "Supplies"
    expect(Support::Framework.first.expires_at).to eql Date.parse("2022-12-31")
  end
end
