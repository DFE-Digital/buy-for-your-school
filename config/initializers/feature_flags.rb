require "feature_flags"

Features = FeatureFlags.new(Rails.configuration.feature_flags)
