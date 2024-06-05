# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.append_after do
    DatabaseCleaner.clean
    FactoryBot.reload
    Faker::UniqueGenerator.clear
    clear_all_sequences
  end

  def clear_all_sequences
    statement = <<-SQL
      DO $$
      DECLARE
        seq RECORD;
      BEGIN
        FOR seq IN
          SELECT sequence_schema, sequence_name
          FROM information_schema.sequences
        LOOP
          EXECUTE format('ALTER SEQUENCE %I.%I RESTART WITH 1', seq.sequence_schema, seq.sequence_name);
        END LOOP;
      END $$;
    SQL
    ActiveRecord::Base.connection.execute(statement)
  end
end
