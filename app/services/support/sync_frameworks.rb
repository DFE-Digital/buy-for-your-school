module Support
  class SyncFrameworks
    include InsightsTrackable

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
        is_exist = Frameworks::Framework.find_by(name: faf[:name], provider_id: faf[:provider_id])
        if is_exist
          Frameworks::Framework.find_by(
            name: faf[:name], 
            provider_id: faf[:provider_id])
            .update(
              faf_slug_ref: faf[:faf_slug_ref],
              faf_category: faf[:faf_category],
              provider_end_date: faf[:provider_end_date],
              url: faf[:url],
              description: faf[:description],
              source: 2,
              status: get_expired_status(faf[:provider_end_date])
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
            status: get_expired_status(faf[:provider_end_date])
          )
          new_record.save!
        end
      end

      #check archived framework
      update_archive_status(prepared_frameworks)
      #check expired framework
      update_expired_status()
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
          status: get_expired_status(Date.parse(framework["expiry"]))
        }
      end
    end

    def check_expired_status(provider_end_date)
      return provider_end_date && provider_end_date < Date.today ? true : false
    end

    def get_expired_status(provider_end_date)
      return provider_end_date && provider_end_date < Date.today ? 5 : 3
    end

    def get_provider_id(provider_short_name, provider_name)
      #check provider name exist
      provider_detail = Frameworks::Provider.where('lower(short_name) = ?', provider_short_name.downcase).first
      if provider_detail
        if provider_detail.name != provider_name
          Frameworks::Provider.find_by(id: provider_detail.id).update(name: provider_name)  #to update provider name when title is diff
        end
        return provider_detail.id
      else 
        @provider = Frameworks::Provider.new(short_name: provider_short_name, name: provider_name)
        if @provider.save
          provider_id = @provider.id  # This will give you the ID of the inserted record
        end
        return provider_id
      end
    end

    def update_archive_status(prepared_frameworks)
      cms_framework = Frameworks::Framework.where(source: 2)

      cms_framework.each do |cms_framework|
        is_exist = false
        prepared_frameworks.each do |faf_framework|
          if cms_framework.name == faf_framework[:name] && cms_framework.provider_id == faf_framework[:provider_id]
            is_exist = true
          end
        end
        if !is_exist
          #update framewok data as archived when no matching data found in FAF end point
          Frameworks::Framework.find_by(
            name: cms_framework.name, 
            provider_id: cms_framework.provider_id)
            .update(
              status: 6,
              is_archived: true,
              faf_archived_at: Date.today
            )
        end
      end
    end

    def update_expired_status
      cms_framework = Frameworks::Framework.all

      cms_framework.each do |cms_framework|
        if check_expired_status(cms_framework.provider_end_date)
          Frameworks::Framework.find_by(id: cms_framework.id).update(status: 5)
        end
      end
    end
  end
end
