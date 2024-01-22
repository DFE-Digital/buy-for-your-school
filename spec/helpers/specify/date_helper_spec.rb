require "rails_helper"

RSpec.describe DateHelper, type: :helper do
  describe "#format_date" do
    it "returns a Date object from params" do
      params = { day: "1", month: "2", year: "2020" }
      expect(helper.format_date(params)).to eq(Date.new(2020, 2, 1))
    end

    it "returns nil when passed nil" do
      params = {}
      expect(helper.format_date(params)).to be_nil
    end

    it "returns nil when the date params are incomplete" do
      params = { day: "", month: "", year: "2019" }
      expect(helper.format_date(params)).to eq(nil)
    end

    it "returns nil when given an invalid date" do
      params = { day: "40", month: "13", year: "2020" }
      expect(helper.format_date(params)).to eq(nil)
    end

    it "returns nil when given a zero parameter" do
      params = { day: "40", month: "0", year: "2020" }
      expect(helper.format_date(params)).to eq(nil)
    end
  end

  describe "#short_date_format" do
    before { travel_to Time.zone.local(2023, 3, 7, 0, 0) }
    after { travel_back }

    context "when the date takes place the same year" do
      it "excludes the year" do
        expect(helper.short_date_format("2023-02-25 15:58")).to eq "25 Feb 15:58"
      end
    end

    context "when the date takes place in a previous year" do
      it "includes the year" do
        expect(helper.short_date_format("2020-11-03 18:01")).to eq "03 Nov 2020 18:01"
      end
    end

    it "allows to hide the time" do
      expect(helper.short_date_format("2025-07-12 00:00", show_time: false)).to eq "12 Jul 2025"
    end

    it "allows to always show the year" do
      expect(helper.short_date_format("2023-01-20 02:13", always_show_year: true)).to eq "20 Jan 2023 02:13"
    end
  end

  describe "#relative_date_format" do
    before { travel_to Time.zone.local(2023, 3, 7, 0, 0) }
    after { travel_back }

    context "when the date is the current date" do
      it "calls simple_distance_of_time_in_words" do
        allow(helper).to receive(:simple_distance_of_time_in_words).with(Time.zone.parse("2023-03-07 15:58"), Time.zone.now)

        helper.relative_date_format("2023-03-07 15:58")

        expect(helper).to have_received(:simple_distance_of_time_in_words).with(Time.zone.parse("2023-03-07 15:58"), Time.zone.now).once
      end
    end

    context "when the date is not the current date" do
      it "calls short_date_format" do
        allow(helper).to receive(:short_date_format).with(Time.zone.parse("2023-03-06 15:58"), show_time: false)

        helper.relative_date_format("2023-03-06 15:58")

        expect(helper).to have_received(:short_date_format).with(Time.zone.parse("2023-03-06 15:58"), show_time: false).once
      end
    end
  end
end
