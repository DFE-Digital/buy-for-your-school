# See https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2045870109/Configuring+Rails+logger+for+GOVUK+PaaS

unless Rails.env.test?
  Rails.application.configure do
    config.semantic_logger.application = "" # This is added by logstash from the paas tags
    config.log_tags = [:request_id] # Prepend all log lines with the following tags.
  end

  SemanticLogger.add_appender(io: STDOUT, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
  Rails.application.config.logger.info('Application logging to STDOUT')
end
