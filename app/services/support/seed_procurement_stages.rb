require "yaml"

module Support
  class SeedProcurementStages
    def initialize(data: "./config/support/procurement_stages.yml")
      @data = data
    end

    def call
      yaml = YAML.load_file(@data)
      load_procurement_stages!(yaml["procurement_stages"])
    end

    def load_procurement_stages!(procurement_stages)
      procurement_stages.each do |stage, sub_stages|
        sub_stages.each do |sub_stage|
          record = Support::ProcurementStage.find_or_initialize_by(key: sub_stage["key"])
          record.title = sub_stage["title"]
          record.stage = stage
          record.archived = sub_stage["is_archived"] == true
          record.save!
        end
      end
    end
  end
end
