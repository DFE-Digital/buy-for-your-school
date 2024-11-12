module Support
  class SyncFrameworks
    include InsightsTrackable

    delegate :statuses, to: Frameworks::Framework

    def initialize(endpoint: ENV["FAF_FRAMEWORK_ENDPOINT"])
      @endpoint = endpoint
    end

    def call
      fetch_frameworks
      update_frameworks if @frameworks.present?
    end

  private

    def fetch_frameworks
      uri = URI.parse(@endpoint)
      response =
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          request = Net::HTTP::Get.new(uri)
          http.request(request)
        end

      if response.code == "200"
        @frameworks = JSON.parse(response.body)
      else
        track_error("SyncFrameworks/CouldNotFetchFrameworks", uri: @endpoint, status: response.code)
      end
    end

    def update_frameworks
      prepared_frameworks = prepare_frameworks(@frameworks)

      prepared_frameworks.each do |faf|
        record = Frameworks::Framework.find_or_initialize_by(name: faf[:name], provider_id: faf[:provider_id])
        record.faf_slug_ref = faf[:faf_slug_ref]
        record.faf_category = faf[:faf_category]
        record.provider_end_date = faf[:provider_end_date]
        record.url = faf[:url]
        record.description = faf[:description]
        record.source = 2
        record.status = get_expired_status(faf[:provider_end_date])
        record.save!
      end

      # check archived framework
      update_archive_status(prepared_frameworks)
      # check expired framework
      update_expired_status
    end

    def prepare_frameworks(frameworks)
      frameworks.select { |framework| framework["expiry"].present? }.map do |framework|
        {
          name: framework["title"],
          faf_slug_ref: framework["ref"],
          provider_id: existing_provider(framework["provider"].try(:[], "initials"), framework["provider"].try(:[], "title")),
          faf_category: framework["cat"].try(:[], "title"),
          provider_end_date: Date.parse(framework["expiry"]),
          url: framework["url"],
          description: framework["descr"],
          source: 2,
          status: get_expired_status(Date.parse(framework["expiry"])),
        }
      end
    end

    def expired?(provider_end_date)
      provider_end_date && provider_end_date < Time.zone.today
    end

    def get_expired_status(provider_end_date)
      provider_end_date && provider_end_date < Time.zone.today ? statuses["expired"] : statuses["dfe_approved"]
    end

    def existing_provider(provider_short_name, provider_name)
      # check provider name exist
      provider_detail = Frameworks::Provider.find_by("lower(short_name) = lower(?)", provider_short_name)
      if provider_detail
        if provider_detail.name != provider_name
          provider_detail.update!(name: provider_name) # to update provider name when title is diff
        end
      else
        provider_detail = Frameworks::Provider.new(short_name: provider_short_name, name: provider_name)
        provider_detail.save!
      end
      provider_detail.id
    end

    def update_archive_status(prepared_frameworks)
      cms_frameworks = Frameworks::Framework.where(source: 2)

      cms_frameworks.each do |cms_framework|
        is_exist = 0
        prepared_frameworks.each do |faf_framework|
          if cms_framework.name == faf_framework[:name] && cms_framework.provider_id == faf_framework[:provider_id]
            is_exist = 1
          end
        end

        next unless is_exist.zero?

        Frameworks::Framework.find_by!(
          name: cms_framework.name,
          provider_id: cms_framework.provider_id,
        )
          .update!(
            status: statuses["archived"],
            is_archived: true,
            faf_archived_at: Time.zone.today,
          )
      end
    end

    def update_expired_status
      cms_frameworks = Frameworks::Framework.all

      cms_frameworks.each do |cms_framework|
        if expired?(cms_framework.provider_end_date) && cms_framework.status != "archived"
          Frameworks::Framework.find_by!(id: cms_framework.id).update!(status: statuses["expired"])
        end
      end
    end
  end
end
