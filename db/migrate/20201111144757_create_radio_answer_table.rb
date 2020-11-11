class CreateRadioAnswerTable < ActiveRecord::Migration[6.0]
  def up
    create_table :radio_answers, id: :uuid do |t|
      t.references :question, type: :uuid
      t.string :response, null: false
      t.timestamps
    end

    questions = Question.where(contentful_type: "radios")
    ActiveRecord::Base.transaction do
      questions.each.map do |question|
        next if question.answer.nil?
        original_answer = question.answer.clone
        new_answer = RadioAnswer.new(
          question_id: original_answer.question_id,
          response: original_answer.response,
          created_at: original_answer.created_at,
          updated_at: original_answer.updated_at
        )

        if new_answer.valid?
          question.answer.destroy!
          new_answer.save!
        end
      end
    end
  end

  def down
    questions = Question.where(contentful_type: "radios")
    ActiveRecord::Base.transaction do
      questions.each.map do |question|
        next if question.answer.nil?
        radio_answer = question.answer
        new_answer = Answer.new(
          question_id: radio_answer.question_id,
          response: radio_answer.response,
          created_at: radio_answer.created_at,
          updated_at: radio_answer.updated_at
        )

        if new_answer.valid?
          question.answer.destroy!
          new_answer.save!
        end
      end
    end

    drop_table :radio_answers
  end
end
