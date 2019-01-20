# frozen_string_literal: true

require 'sequel'

FileUtils.mkdir_p('log')
require 'logger'
DB.loggers << Logger.new('log/sequel.log')

RSpec.configure do |config|
  config.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
  end

  config.around(:example, :db) do |example|
    DB.transaction(rollback: :always) do 
      DB.log_info("Starting example #{example.full_description}")
      example.run 
      DB.log_info("Ending example #{example.full_description}")
    end
  end
end
