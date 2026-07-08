require "rails_helper"

RSpec.describe "Azure AI search tasks" do
  before do
    Rake.application.rake_require("tasks/azure_ai_search")
    Rake::Task.define_task(:environment)
  end

  after do
    Rake::Task["azure_ai_search:create_index"].reenable
    Rake::Task["azure_ai_search:index"].reenable
    Rake::Task["azure_ai_search:count"].reenable
    Rake::Task["azure_ai_search:clear"].reenable
  end

  describe "azure_ai_search:create_index" do
    subject(:invoke_task) { Rake::Task["azure_ai_search:create_index"].invoke }

    let(:client) { instance_double(AzureAiSearch::Client) }

    before do
      allow(AzureAiSearch::Client).to receive(:new).and_return(client)
    end

    context "when the index does not exist" do
      before do
        allow(client).to receive(:index_exists?).with(index_name: "solution-data").and_return(false)
        allow(client).to receive(:create_index)
      end

      it "creates the solution index" do
        expect(client).to receive(:create_index).with(body: AzureAiSearch::SolutionIndexSchema.to_h)

        expect { invoke_task }
          .to output("Creating Azure AI Search index solution-data...\nCreated Azure AI Search index solution-data.\n")
          .to_stdout
      end
    end

    context "when the index already exists" do
      before do
        allow(client).to receive(:index_exists?).with(index_name: "solution-data").and_return(true)
      end

      it "does not recreate the index" do
        expect(client).not_to receive(:create_index)

        expect { invoke_task }
          .to output("Azure AI Search index solution-data already exists.\n")
          .to_stdout
      end
    end
  end

  describe "azure_ai_search:index" do
    subject(:invoke_task) { Rake::Task["azure_ai_search:index"].invoke }

    let(:client) { instance_double(AzureAiSearch::Client) }
    let(:indexer) { instance_double(AzureAiSearch::SolutionIndexer) }

    before do
      allow(AzureAiSearch::Client).to receive(:new).and_return(client)
      allow(AzureAiSearch::SolutionIndexer).to receive(:new).with(client:).and_return(indexer)
      allow(Solution).to receive(:all).and_return(%w[solution-1 solution-2])
      allow(indexer).to receive(:index_all).with(%w[solution-1 solution-2]).and_return(
        [{ "value" => [{ "status" => true }, { "status" => false }] }],
      )
      allow(client).to receive(:document_count).with(index_name: "solution-data").and_return(1)
    end

    it "indexes solutions and prints the API document count" do
      expect { invoke_task }
        .to output(
          "Starting Contentful to Azure AI Search sync...\n" \
          "Successfully indexed 1 of 2 solutions into Azure AI Search.\n" \
          "Azure AI Search document count for solution-data: 1\n",
        )
        .to_stdout
    end
  end

  describe "azure_ai_search:count" do
    subject(:invoke_task) { Rake::Task["azure_ai_search:count"].invoke }

    let(:client) { instance_double(AzureAiSearch::Client) }

    before do
      allow(AzureAiSearch::Client).to receive(:new).and_return(client)
      allow(client).to receive(:document_count).with(index_name: "solution-data").and_return(64)
    end

    it "prints the API document count" do
      expect { invoke_task }
        .to output("Azure AI Search document count for solution-data: 64\n")
        .to_stdout
    end
  end

  describe "azure_ai_search:clear" do
    subject(:invoke_task) { Rake::Task["azure_ai_search:clear"].invoke }

    let(:client) { instance_double(AzureAiSearch::Client) }

    before do
      allow(AzureAiSearch::Client).to receive(:new).and_return(client)
      allow(client).to receive(:document_count).with(index_name: "solution-data").and_return(0)
    end

    context "when the index has documents" do
      before do
        allow(client).to receive(:search).with(
          index_name: "solution-data",
          body: {
            search: "*",
            select: "id",
            top: 1000,
          },
        ).and_return("value" => [{ "id" => "solution-1" }, { "id" => "solution-2" }])
        allow(client).to receive(:index_documents).and_return(
          "value" => [{ "status" => true }, { "status" => true }],
        )
      end

      it "deletes documents from the index" do
        expect(client).to receive(:index_documents).with(
          index_name: "solution-data",
          documents: [
            { "@search.action": "delete", id: "solution-1" },
            { "@search.action": "delete", id: "solution-2" },
          ],
        )

        expect { invoke_task }
          .to output(
            "Clearing Azure AI Search index solution-data...\n" \
            "Deleted 2 documents from Azure AI Search index solution-data.\n" \
            "Azure AI Search document count for solution-data: 0\n",
          )
          .to_stdout
      end
    end

    context "when the index is already empty" do
      before do
        allow(client).to receive(:search).and_return("value" => [])
      end

      it "does not send delete actions" do
        expect(client).not_to receive(:index_documents)

        expect { invoke_task }
          .to output(
            "Clearing Azure AI Search index solution-data...\n" \
            "Azure AI Search index solution-data is already empty.\n",
          )
          .to_stdout
      end
    end
  end
end
