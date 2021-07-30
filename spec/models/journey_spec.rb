require "rails_helper"

RSpec.describe Journey, type: :model do
  it { is_expected.to have_many(:sections) }

  it "captures the category" do
    category = build(:category, :catering)
    journey = build(:journey, category: category)
    expect(journey.category.title).to eql("Catering")
  end

  describe "#all_tasks_completed?" do
    context "when all steps have been completed" do
      it "returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step1 = create(:step, :radio, task: task)
        create(:radio_answer, step: step1)

        step2 = create(:step, :radio, task: task)
        create(:radio_answer, step: step2)

        expect(journey.all_tasks_completed?).to be true
      end
    end

    context "when no steps have been completed" do
      it "returns false " do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        create_list(:step, 2, :radio, task: task)

        expect(journey.all_tasks_completed?).to be false
      end
    end

    context "when only some steps have been completed" do
      it "returns false" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step = create(:step, :radio, task: task)
        create(:radio_answer, step: step)

        create(:step, :radio, task: task)
        # Omit answer for step 2

        expect(journey.all_tasks_completed?).to be false
      end
    end

    context "when there are uncompleted hidden steps" do
      it "ignores them and returns true" do
        journey = create(:journey)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        step = create(:step, :radio, task: task)
        create(:radio_answer, step: step)

        create(:step, :radio, task: task, hidden: true)
        # Omit answer for step 2

        expect(journey.all_tasks_completed?).to be true
      end
    end
  end

  describe "#start!" do
    it "set started to true" do
      category = build(:category, :catering)
      journey = build(:journey, category: category)
      journey.start!
      expect(journey.reload.started).to eq(true)
    end

    it "sets the updated_at to now" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      category = build(:category, :catering)
      journey = build(:journey, category: category)

      journey.start!

      expect(journey.updated_at).to eq(Time.zone.now)
    end

    context "when started is already true" do
      it "does not update the record" do
        category = build(:category, :catering)
        journey = build(:journey, category: category, started: true)
        expect(journey).not_to receive(:update).with(started: true)
        journey.start!
      end
    end
  end

  describe "#next_incomplete_task" do
    let(:category) { create(:category, :catering) }
    let(:journey) { create(:journey, category: category) }
    let(:section_a) { create(:section, title: "Section A", journey: journey, order: 0) }
    let(:section_b) { create(:section, title: "Section B", journey: journey, order: 1) }
    let(:section_c) { create(:section, title: "Section C", journey: journey, order: 2) }
    let(:tasks) { build_tasks(3) }

    before do
      tasks.values.each(&:save!)
    end

    context "when starting sequentially from the top down" do
      describe "Task A-0 -> Task A-1 -> Task A-2 -> Task B-0" do
        before do
          tasks[:a0].steps.each { |step| create(:number_answer, step: step) }
        end

        it "A-0 -> A-1" do
          expect(journey.next_incomplete_task(tasks[:a0])).to eq tasks[:a1]
        end

        it "A-1 -> A-2" do
          tasks[:a1].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:a1])).to eq tasks[:a2]
        end

        it "A-2 -> B-0" do
          tasks[:a1].steps.each { |step| create(:number_answer, step: step) }
          tasks[:a2].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:a2])).to eq tasks[:b0]
        end
      end
    end

    context "when starting from a middle task" do
      describe "Task A-1 -> Task A-2 -> Task A-0" do
        before do
          tasks[:a1].steps.each { |step| create(:number_answer, step: step) }
        end

        it "A-1 -> A-2" do
          expect(journey.next_incomplete_task(tasks[:a1])).to eq tasks[:a2]
        end

        it "A-2 -> A-0" do
          tasks[:a2].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:a2])).to eq tasks[:a0]
        end
      end
    end

    context "when starting from a middle section" do
      describe "Task B-1 -> Task B-2 -> Task B-0 -> Task C-0" do
        before do
          tasks[:b1].steps.each { |step| create(:number_answer, step: step) }
        end

        it "B-1 -> B-2" do
          expect(journey.next_incomplete_task(tasks[:b1])).to eq tasks[:b2]
        end

        it "B-2 -> B-0" do
          tasks[:b2].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:b2])).to eq tasks[:b0]
        end

        it "B-0 -> C-0" do
          tasks[:b2].steps.each { |step| create(:number_answer, step: step) }
          tasks[:b0].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:b0])).to eq tasks[:c0]
        end
      end
    end

    context "when starting from the last section" do
      describe "Task C-0 -> Task C-1 -> Task C-2 -> Task A-0" do
        before do
          tasks[:c0].steps.each { |step| create(:number_answer, step: step) }
        end

        it "C-0 -> C-1" do
          expect(journey.next_incomplete_task(tasks[:c0])).to eq tasks[:c1]
        end

        it "C-1 -> C-2" do
          tasks[:c1].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:c1])).to eq tasks[:c2]
        end

        it "C-2 -> A-0" do
          tasks[:c1].steps.each { |step| create(:number_answer, step: step) }
          tasks[:c2].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:c2])).to eq tasks[:a0]
        end
      end
    end

    context "when a step is hidden, top down" do
      describe "Task A-0 -> skip hidden Task A-1 -> Task A-2 -> Task B-0" do
        before do
          tasks[:a1].steps.each(&:delete)
          create(:step, :number, hidden: true, task: tasks[:a1])

          tasks[:a0].steps.each { |step| create(:number_answer, step: step) }
        end

        it "A-0 -> A-2" do
          expect(journey.next_incomplete_task(tasks[:a0])).to eq tasks[:a2]
        end

        it "A-2 -> B-0" do
          tasks[:a2].steps.each { |step| create(:number_answer, step: step) }
          expect(journey.next_incomplete_task(tasks[:a2])).to eq tasks[:b0]
        end
      end
    end

    context "when a step is hidden and then revealed, top down" do
      describe "Task A-0 -> skip hidden Task A-1 -> Task A-2 -> reveal Task A-1 -> Task B-0" do
        before do
          tasks[:a1].steps.each { |step| step.update!(hidden: true) }
          tasks[:a0].steps.each { |step| create(:number_answer, step: step) }
        end

        it "A-0 -> A-2" do
          expect(journey.next_incomplete_task(tasks[:a0])).to eq tasks[:a2]
        end

        it "A-2 -> A-1" do
          tasks[:a2].steps.each { |step| create(:number_answer, step: step) }
          tasks[:a1].steps.each { |step| step.update!(hidden: false) }

          expect(journey.next_incomplete_task(tasks[:a2])).to eq tasks[:a1]
        end

        it "A-1 -> B-0" do
          tasks[:a2].steps.each { |step| create(:number_answer, step: step) }
          tasks[:a1].steps.each do |step|
            step.update!(hidden: false)
            create(:number_answer, step: step)
          end

          expect(journey.next_incomplete_task(tasks[:a1])).to eq tasks[:b0]
        end
      end
    end

    def build_tasks(num)
      hash = {}
      num.times do |index|
        hash["a#{index}".to_sym] = build(:task, :with_steps, section: section_a, title: "Task A-#{index}", order: index)
        hash["b#{index}".to_sym] = build(:task, :with_steps, section: section_b, title: "Task B-#{index}", order: index)
        hash["c#{index}".to_sym] = build(:task, :with_steps, section: section_c, title: "Task C-#{index}", order: index)
      end
      hash
    end
  end
end
