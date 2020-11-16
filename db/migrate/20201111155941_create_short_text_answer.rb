class CreateShortTextAnswer < ActiveRecord::Migration[6.0]
  def up
    create_table :short_text_answers, id: :uuid do |t|
      t.references :question, type: :uuid
      t.string :response, null: false
      t.timestamps
    end

    questions = Question.where(contentful_type: "short_text")
    ActiveRecord::Base.transaction do
      questions.each.map do |question|
        next if question.answer.nil?
        original_answer = question.answer
        new_answer = ShortTextAnswer.new(
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
    questions = Question.where(contentful_type: "short_text")
    ActiveRecord::Base.transaction do
      questions.each.map do |question|
        next if question.answer.nil?
        short_text_answer = question.answer
        new_answer = Answer.new(
          question_id: short_text_answer.question_id,
          response: short_text_answer.response,
          created_at: short_text_answer.created_at,
          updated_at: short_text_answer.updated_at
        )

        if new_answer.valid?
          question.answer.destroy!
          new_answer.save!
        end
      end
    end

    drop_table :short_text_answers
  end
end
