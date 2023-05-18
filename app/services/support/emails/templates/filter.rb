module Support
  module Emails
    module Templates
      class Filter
        ALL_NONE_VALUES = { all: "all", none: "none" }.freeze

        def self.all_none_values = ALL_NONE_VALUES

        def initialize
          @results = Support::EmailTemplate.active
        end

        def by_groups(group, subgroups: [])
          return self if group.blank?

          @results =
            if subgroups.include?(ALL_NONE_VALUES[:all])
              @results.by_groups([group] + get_subgroups(group))
            elsif subgroups.include?(ALL_NONE_VALUES[:none])
              @results.by_groups([group] + subgroups)
            elsif subgroups.blank?
              @results.by_groups(group)
            else
              @results.by_groups(subgroups)
            end
          self
        end

        def by_stages(stages)
          return self if stages.include?(ALL_NONE_VALUES[:all]) || stages.blank?

          @results =
            if stages.include?(ALL_NONE_VALUES[:none])
              @results.by_stages(stages, include_null: true)
            else
              @results.by_stages(stages)
            end
          self
        end

        def results
          @results.to_a
        end

      private

        def get_subgroups(group)
          Support::EmailTemplateGroup.find(group).sub_groups.map(&:id)
        end
      end
    end
  end
end
