require "rails_helper"

describe Support::Management::EmailTemplateFilterForm, type: :model do
  subject(:form) { described_class.new(**params) }

  let(:group_id) { nil }
  let(:subgroup_ids) { [] }
  let(:stages) { [] }
  let(:remove_group) { nil }
  let(:remove_subgroup) { nil }
  let(:remove_stage) { nil }

  let(:params) { { group_id:, subgroup_ids:, stages:, remove_group:, remove_subgroup:, remove_stage: } }

  let!(:group_energy) { create(:support_email_template_group, title: "Energy") }
  let!(:group_fm) { create(:support_email_template_group, title: "FM") }
  let!(:subgroup_fm_catering) { create(:support_email_template_group, title: "Catering", parent: group_fm) }
  let!(:subgroup_fm_cleaning) { create(:support_email_template_group, title: "Cleaning", parent: group_fm) }

  context "when filters include empty strings" do
    let(:subgroup_ids) { ["", "1", "2"] }
    let(:stages) { ["", "3", "4"] }

    it "removes the empty strings" do
      expect(form.subgroup_ids).to eq %w[1 2]
      expect(form.stages).to eq %w[3 4]
    end
  end

  context "when no filters are provided" do
    let(:subgroup_ids) { [] }
    let(:stages) { [] }

    it "filters for all subgroups" do
      expect(form.subgroup_ids).to eq %w[all]
    end

    it "filters for all stages" do
      expect(form.stages).to eq %w[all]
    end
  end

  context "when filters are selected for removal" do
    context "when the group tag is selected for removal" do
      let(:group_id) { "any" }
      let(:remove_group) { "any" }

      it "sets the group ID to nil" do
        expect(form.group_id).to be_nil
      end
    end

    context "when a subgroup tag is selected for removal" do
      let(:subgroup_ids) { %w[1 2] }
      let(:remove_subgroup) { "1" }

      it "removes the selected tag" do
        expect(form.subgroup_ids).to eq %w[2]
      end
    end

    context "when a stage tag is selected for removal" do
      let(:stages) { %w[3 4] }
      let(:remove_stage) { "4" }

      it "removes the selected tag" do
        expect(form.stages).to eq %w[3]
      end
    end
  end

  describe "#group_options" do
    it "returns all groups as title-id arrays" do
      expect(form.group_options).to eq [[group_energy.title, group_energy.id], [group_fm.title, group_fm.id]]
    end
  end

  describe "#subgroup_options" do
    context "when no group is selected" do
      let(:group_id) { nil }

      it "returns an empty array" do
        expect(form.subgroup_options).to be_empty
      end
    end

    context "when a group is selected" do
      let(:group_id) { group_fm.id }

      it "returns all subgroups as id-title-exclusive objects" do
        expect(form.subgroup_options).to eq [
          OpenStruct.new(id: "all", title: "All subgroups", exclusive: true),
          OpenStruct.new(id: "none", title: "No subgroup", exclusive: false),
          OpenStruct.new(id: subgroup_fm_catering.id, title: subgroup_fm_catering.title, exclusive: false),
          OpenStruct.new(id: subgroup_fm_cleaning.id, title: subgroup_fm_cleaning.title, exclusive: false),
        ]
      end
    end
  end

  describe "#stage_options" do
    it "returns all stages as id-title-exclusive objects" do
      expect(form.stage_options).to eq [
        OpenStruct.new(id: "all", title: "All stages", exclusive: true),
        OpenStruct.new(id: "none", title: "No stage", exclusive: false),
        OpenStruct.new(id: "0", title: "Stage 0", exclusive: false),
        OpenStruct.new(id: "1", title: "Stage 1", exclusive: false),
        OpenStruct.new(id: "2", title: "Stage 2", exclusive: false),
        OpenStruct.new(id: "3", title: "Stage 3", exclusive: false),
        OpenStruct.new(id: "4", title: "Stage 4", exclusive: false),
      ]
    end
  end

  describe "#has_subgroups?" do
    context "when no group is selected" do
      let(:group_id) { nil }

      it "returns false" do
        expect(form.has_subgroups?).to eq false
      end
    end

    context "when a group is selected" do
      context "and it has subgroups" do
        let(:group_id) { group_fm.id }

        it "returns true" do
          expect(form.has_subgroups?).to eq true
        end
      end

      context "and it has no subgroups" do
        let(:group_id) { group_energy.id }

        it "returns false" do
          expect(form.has_subgroups?).to eq false
        end
      end
    end
  end

  describe "#tags" do
    describe "group tags" do
      context "when a group is selected" do
        let(:group_id) { group_energy.id }

        it "returns a tag for the group" do
          expect(form.tags).to eq [OpenStruct.new(id: group_energy.id, title: group_energy.title, type: :group)]
        end
      end

      context "when no group is selected" do
        let(:group_id) { nil }

        it "returns no tag for the group" do
          expect(form.tags).to be_empty
        end
      end
    end

    describe "subgroup tags" do
      let(:group_id) { group_fm.id }

      context "when subgroups include 'all'" do
        let(:subgroup_ids) { %w[all] }

        it "returns no subgroup tags" do
          expect(form.tags).to eq [OpenStruct.new(id: group_fm.id, title: group_fm.title, type: :group)]
        end
      end

      context "when subgroups do not include 'all'" do
        let(:subgroup_ids) { [subgroup_fm_catering.id, subgroup_fm_cleaning.id] }

        it "returns the subgroup tags" do
          expect(form.tags).to eq [
            OpenStruct.new(id: group_fm.id, title: group_fm.title, type: :group),
            OpenStruct.new(id: subgroup_fm_catering.id, title: subgroup_fm_catering.title, type: :subgroup),
            OpenStruct.new(id: subgroup_fm_cleaning.id, title: subgroup_fm_cleaning.title, type: :subgroup),
          ]
        end
      end
    end

    describe "stage tags" do
      context "when stages include 'all'" do
        let(:stages) { %w[all] }

        it "returns no stage tags" do
          expect(form.tags).to be_empty
        end
      end

      context "when stages do not include 'all'" do
        let(:stages) { %w[0 1 2 3 4] }

        it "returns the stage tags" do
          expect(form.tags).to eq [
            OpenStruct.new(id: "0", title: "Stage 0", type: :stage),
            OpenStruct.new(id: "1", title: "Stage 1", type: :stage),
            OpenStruct.new(id: "2", title: "Stage 2", type: :stage),
            OpenStruct.new(id: "3", title: "Stage 3", type: :stage),
            OpenStruct.new(id: "4", title: "Stage 4", type: :stage),
          ]
        end
      end
    end
  end

  describe "#results" do
    let(:group_id) { group_energy.id }
    let(:subgroup_ids) { %w[1 2] }
    let(:stages) { %w[3 4] }

    let(:filter_service_double) { instance_double(Support::Emails::Templates::Filter) }

    before do
      allow(Support::Emails::Templates::Filter).to receive(:new).and_return(filter_service_double)
      allow(filter_service_double).to receive(:by_groups).and_return(filter_service_double)
      allow(filter_service_double).to receive(:by_stages).and_return(filter_service_double)
      allow(filter_service_double).to receive(:results)

      form.results
    end

    it "calls the filter service for results" do
      expect(filter_service_double).to have_received(:by_groups).with(group_id, subgroups: subgroup_ids)
      expect(filter_service_double).to have_received(:by_stages).with(stages)
      expect(filter_service_double).to have_received(:results)
    end
  end
end
