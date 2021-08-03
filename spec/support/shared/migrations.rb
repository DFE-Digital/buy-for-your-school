RSpec.shared_context "with data migrations" do
  subject(:up) do
    ActiveRecord::Migrator.new(:up, migrations, schema, current_version).migrate
  end

  let(:down) do
    ActiveRecord::Migrator.new(:down, migrations, schema, previous_version).migrate
  end

  let(:migrations_paths) do
    ActiveRecord::Migrator.migrations_paths
  end

  let(:schema) do
    ActiveRecord::Base.connection.schema_migration
  end

  let(:migrations) do
    ActiveRecord::MigrationContext.new(migrations_paths, schema).migrations
  end

  let(:previous_version) { nil }
  let(:current_version) { nil }

  before do
    ActiveRecord::Migration.suppress_messages { down }
  end

  after do
    ActiveRecord::Migration.suppress_messages { up }
  end
end
