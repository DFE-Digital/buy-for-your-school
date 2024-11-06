require "rails_helper"

describe Frameworks::Framework::Sortable do
  subject(:sortable) { Frameworks::Framework }

  describe "sorting" do
    subject(:results) { sortable.sorted_by(sort_by:, sort_order:) }

    describe "by reference" do
      let(:sort_by) { "reference" }

      before do
        create(:frameworks_framework, reference: "F3")
        create(:frameworks_framework, reference: "F200")
        create(:frameworks_framework, reference: "F1000")
      end

      describe "sorting ascending" do
        let(:sort_order) { "ascending" }

        it "returns all results ordered by reference alphabetically with lowest appearing first" do
          expect(results.pluck(:reference)).to eq(%w[F3 F200 F1000])
        end
      end

      describe "sorting descending" do
        let(:sort_order) { "descending" }

        it "returns all results ordered by reference alphabetically with highest appearing first" do
          expect(results.pluck(:reference)).to eq(%w[F1000 F200 F3])
        end
      end
    end

    describe "by date fields" do
      %w[
        dfe_review_date
        provider_start_date
        provider_end_date
      ].each do |date_field|
        describe "by #{date_field}" do
          let(:sort_by) { date_field }

          before do
            create(:frameworks_framework, name: "Earliest #{date_field} date", date_field => 2.weeks.ago)
            create(:frameworks_framework, name: "Middle #{date_field} date", date_field => 1.week.ago)
            create(:frameworks_framework, name: "Latest #{date_field} date", date_field => 1.day.ago)
          end

          describe "sorting ascending" do
            let(:sort_order) { "ascending" }

            it "returns all results ordered by #{date_field} date with earliest appearing first" do
              expect(results.pluck(:name)).to eq([
                "Earliest #{date_field} date",
                "Middle #{date_field} date",
                "Latest #{date_field} date",
              ])
            end
          end

          describe "sorting descending" do
            let(:sort_order) { "descending" }

            it "returns all results ordered by #{date_field} date with latest appearing first" do
              expect(results.pluck(:name)).to eq([
                "Latest #{date_field} date",
                "Middle #{date_field} date",
                "Earliest #{date_field} date",
              ])
            end
          end
        end
      end
    end
  end
end
