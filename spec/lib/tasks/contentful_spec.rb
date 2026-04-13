RSpec.describe "Contentful tasks" do
  before do
    Rake.application.rake_require("tasks/contentful")
    Rake::Task.define_task(:environment)
  end

  after do
    # Allow each task to be invoked multiple times for testing
    Rake::Task["contentful:check_solution_urls"].reenable
    Rake::Task["contentful:unpublish_expired_solutions"].reenable
    Rake::Task["contentful:update_solution_with_primary_category"].reenable
  end

  describe "contentful:check_solution_urls" do
    subject(:invoke_task) { Rake::Task["contentful:check_solution_urls"].invoke }

    let(:valid_solution) do
      instance_double(Solution, id: "solution-1", title: "Valid solution", slug: "valid-solution", url: "https://example.com")
    end
    let(:missing_url_solution) do
      instance_double(Solution, id: "solution-2", title: "Missing URL", slug: "missing-url", url: nil)
    end
    let(:invalid_url_solution) do
      instance_double(Solution, id: "solution-3", title: "Invalid URL", slug: "invalid-url", url: "://bad")
    end
    let(:error_solution) do
      instance_double(Solution, id: "solution-4", title: "Error URL", slug: "error-url", url: "https://error.example")
    end

    before do
      allow(Solution).to receive(:all).and_return([
        valid_solution,
        missing_url_solution,
        invalid_url_solution,
        error_solution,
      ])
      allow(Net::HTTP).to receive(:get_response).with(URI.parse(valid_solution.url)).and_return(instance_double(Net::HTTPResponse, code: "200"))
      allow(Net::HTTP).to receive(:get_response).with(URI.parse(error_solution.url)).and_return(instance_double(Net::HTTPResponse, code: "500"))
    end

    it "reports missing, invalid, and unsuccessful solution URLs" do
      expect { invoke_task }
        .to output(
          include("Fetching all solutions and checking URLs...")
            .and(include("Solution 'Missing URL' (ID: solution-2, Slug: missing-url) has no URL."))
            .and(include("ERROR: Invalid URL for 'Invalid URL'"))
            .and(include("ERROR: Status 500 for 'Error URL'"))
            .and(include("URL check complete.")),
        )
        .to_stdout
    end

    context "when there are no solutions" do
      before do
        allow(Solution).to receive(:all).and_return([])
      end

      it "reports that no solutions were found" do
        expect { invoke_task }
          .to output("Fetching all solutions and checking URLs...\nNo solutions found.\nURL check complete.\n")
          .to_stdout
      end
    end
  end

  describe "contentful:unpublish_expired_solutions" do
    subject(:invoke_task) { Rake::Task["contentful:unpublish_expired_solutions"].invoke }

    let(:client) { double("contentful management client", spaces:) }
    let(:spaces) { double("spaces") }
    let(:space) { double("space", environments:) }
    let(:environments) { double("environments") }
    let(:environment) { double("environment", entries:) }
    let(:entries) { double("entries") }

    before do
      allow(Contentful::Management::Client).to receive(:new).with(ENV["CONTENTFUL_CMA_TOKEN"]).and_return(client)
      allow(spaces).to receive(:find).with(ENV["CONTENTFUL_SPACE_ID"]).and_return(space)
      allow(environments).to receive(:find).with(ENV.fetch("CONTENTFUL_ENVIRONMENT", "master")).and_return(environment)
      allow(Rollbar).to receive(:info)
      allow(Rollbar).to receive(:error)
    end

    context "when there are no expired solutions" do
      before do
        allow(entries).to receive(:all).with(
          content_type: "solution",
          "fields.expiry[lt]": Time.zone.today.iso8601,
        ).and_return([])
      end

      it "reports the result to stdout and Rollbar" do
        expect(Rollbar).to receive(:info).with("No expired solutions found", rake_task: "contentful:unpublish_expired_solutions")

        expect { invoke_task }
          .to output("No expired solutions found.\n")
          .to_stdout
      end
    end

    context "when all expired solutions are already unpublished" do
      let(:expired_entry) { double("expired entry", published?: false) }

      before do
        allow(entries).to receive(:all).and_return([expired_entry])
      end

      it "does not unpublish anything" do
        expect(expired_entry).not_to receive(:unpublish)
        expect(Rollbar).to receive(:info).with(
          "All expired solutions already unpublished",
          rake_task: "contentful:unpublish_expired_solutions",
          total_expired: 1,
        )

        expect { invoke_task }
          .to output("Found 1 expired solutions, but all are already unpublished.\n")
          .to_stdout
      end
    end

    context "when there are published expired solutions" do
      let(:published_entry) do
        double(
          "published entry",
          id: "entry-1",
          title: "Expired published",
          fields: { slug: "expired-published", expiry: "2024-01-01" },
          published?: true,
        )
      end
      let(:unpublished_entry) { double("unpublished entry", published?: false) }

      before do
        allow(entries).to receive(:all).and_return([published_entry, unpublished_entry])
        allow(published_entry).to receive(:unpublish)
      end

      it "unpublishes the published expired solutions" do
        expect(published_entry).to receive(:unpublish)
        expect(Rollbar).to receive(:info).with(
          "Unpublished 1 of 1 expired solutions",
          rake_task: "contentful:unpublish_expired_solutions",
          count: 1,
          total: 1,
        )

        expect { invoke_task }
          .to output(
            "Found 1 published expired solutions to unpublish (1 already unpublished)\n" \
            "Unpublished: Expired published (slug: expired-published, expired: 2024-01-01)\n" \
            "Unpublishing complete. 1 of 1 solutions unpublished.\n",
          )
          .to_stdout
      end
    end
  end

  describe "contentful:update_solution_with_primary_category" do
    let(:client) { double("contentful management client", spaces:) }
    let(:spaces) { double("spaces") }
    let(:space) { double("space", environments:) }
    let(:environments) { double("environments") }
    let(:environment) { double("environment", entries:) }
    let(:entries) { double("entries") }
    let(:energy_category) { instance_double(FABS::Category, id: "energy-id", title: "Energy") }
    let(:it_category) { instance_double(FABS::Category, id: "it-id", title: "IT") }

    before do
      allow(Contentful::Management::Client).to receive(:new).with(ENV["CONTENTFUL_CMA_TOKEN"]).and_return(client)
      allow(spaces).to receive(:find).with(ENV["CONTENTFUL_SPACE_ID"]).and_return(space)
      allow(environments).to receive(:find).with("master").and_return(environment)
      allow(FABS::Category).to receive(:all).and_return([energy_category, it_category])
      allow(entries).to receive(:all).with(content_type: "solution", "fields.primary_category" => nil).and_return(contentful_entries)
    end

    context "when running as a dry run" do
      subject(:invoke_task) { Rake::Task["contentful:update_solution_with_primary_category"].invoke("dry_run") }

      let(:category_link) { { "sys" => { "id" => "energy-id" } } }
      let(:entry) { double("entry", title: "Single category solution", categories: [category_link]) }
      let(:contentful_entries) { [entry] }

      it "reports the primary category update without updating or publishing" do
        expect(entry).not_to receive(:update)
        expect(entry).not_to receive(:publish)

        expect { invoke_task }
          .to output(
            "Solution: Single category solution\n" \
            "DRY RUN updating Single category solution with primary_category: Energy\n" \
            "DRY RUN: Single category solution has not been publish\n" \
            "------------------\n",
          )
          .to_stdout
      end
    end

    context "when publishing all matching solutions" do
      subject(:invoke_task) { Rake::Task["contentful:update_solution_with_primary_category"].invoke("publish_all") }

      let(:entry) { double("entry", title: "Audiovisual solutions", categories: []) }
      let(:contentful_entries) { [entry] }

      it "updates and publishes using the mapped primary category" do
        expect(entry).to receive(:update).with(
          primary_category: { "sys" => { "type" => "Link", "linkType" => "Entry", "id" => "it-id" } },
        )
        expect(entry).to receive(:publish)

        expect { invoke_task }
          .to output(
            "Solution: Audiovisual solutions\n" \
            "Audiovisual solutions has been publish\n" \
            "------------------\n",
          )
          .to_stdout
      end
    end

    context "when a matching primary category cannot be found" do
      subject(:invoke_task) { Rake::Task["contentful:update_solution_with_primary_category"].invoke("publish_all") }

      let(:entry) { double("entry", title: "Unknown solution", categories: []) }
      let(:contentful_entries) { [entry] }

      it "skips the entry" do
        expect(entry).not_to receive(:update)
        expect(entry).not_to receive(:publish)

        expect { invoke_task }
          .to output(
            "Solution: Unknown solution\n" \
            "Skipping because is missing a category\n" \
            "------------------\n",
          )
          .to_stdout
      end
    end
  end
end
