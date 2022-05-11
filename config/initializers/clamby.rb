# https://github.com/kobaltz/clamby

if Rails.env.production? || ENV["CLAMAV_ENABLED"] == "1"

  Clamby.configure({
    :check => false,
    :daemonize => true,
    :config_file => nil,
    :error_clamscan_missing => true,
    :error_clamscan_client_error => false,
    :error_file_missing => true,
    :error_file_virus => false,
    :fdpass => false,
    :stream => false,
    :output_level => 'medium', # one of 'off', 'low', 'medium', 'high'
    :executable_path_clamscan => 'clamscan',
    :executable_path_clamdscan => 'clamdscan',
    :executable_path_freshclam => 'freshclam',
  })

else

  class MockClamby
    def self.update
      # :noop
    end

    def self.safe?(_path)
      true
    end
  end

  Clamby = MockClamby

end
