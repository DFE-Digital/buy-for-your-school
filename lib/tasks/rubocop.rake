# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
rescue LoadError
end
# rubocop:enable Lint/SuppressedException
