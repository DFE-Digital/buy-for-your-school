module Support
  class SyncFrameworks
    include InsightsTrackable

    def initialize(endpoint: ENV["FAF_FRAMEWORK_ENDPOINT"])
      @endpoint = endpoint
      @dfe_approved = Frameworks::Framework.statuses["dfe_approved"]
      @expired = Frameworks::Framework.statuses["expired"]
      @archived = Frameworks::Framework.statuses["archived"]
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
        is_exist = Frameworks::Framework.find_by(name: faf[:name], provider_id: faf[:provider_id])
        if is_exist
          Frameworks::Framework.find_by(
            name: faf[:name],
            provider_id: faf[:provider_id],
          )
            .update!(
              faf_slug_ref: faf[:faf_slug_ref],
              faf_category: faf[:faf_category],
              provider_end_date: faf[:provider_end_date],
              url: faf[:url],
              description: faf[:description],
              source: 2,
            )
        else
          new_record = Frameworks::Framework.new(
            name: faf[:name],
            provider_id: faf[:provider_id],
            faf_slug_ref: faf[:faf_slug_ref],
            faf_category: faf[:faf_category],
            provider_end_date: faf[:provider_end_date],
            url: faf[:url],
            description: faf[:description],
            source: 2,
            status: get_expired_status(faf[:provider_end_date]),
          )
          new_record.save!
        end
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
          provider_id: get_provider_id(framework["provider"].try(:[], "initials"), framework["provider"].try(:[], "title")),
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
      provider_end_date && provider_end_date < Time.zone.today ? @expired : @dfe_approved
    end

    def get_provider_id(provider_short_name, provider_name)
      # check provider name exist
      provider_detail = Frameworks::Provider.find_by("lower(short_name) = lower(?)", provider_short_name)
      if provider_detail
        if provider_detail.name != provider_name
          Frameworks::Provider.find_by!(id: provider_detail.id).update!(name: provider_name) # to update provider name when title is diff
        end
        provider_detail.id
      else
        @provider = Frameworks::Provider.new(short_name: provider_short_name, name: provider_name)
        if @provider.save!
          provider_id = @provider.id # This will give you the ID of the inserted record
        end
        provider_id
      end
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
            status: @archived,
            is_archived: true,
            faf_archived_at: Time.zone.today,
          )
      end
    end

    def update_expired_status
      cms_frameworks = Frameworks::Framework.all

      cms_frameworks.each do |cms_framework|
        if expired?(cms_framework.provider_end_date) && cms_framework.status != "archived"
          Frameworks::Framework.find_by!(id: cms_framework.id).update!(status: @expired)
        end
      end
    end
  end
end
