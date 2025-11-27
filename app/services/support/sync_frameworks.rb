module Support
  class SyncFrameworks
    include InsightsTrackable

    delegate :statuses, to: ::Frameworks::Framework

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
        # First try to match by contentful_id (authoritative - single record)
        record = find_framework_by_contentful_id(faf)

        if record
          new_status = determine_new_status(record, faf)
          update_record(record, faf, new_status)
        else
          # Fall back to name + provider matching (preserves old multi-record behavior)
          records = ::Frameworks::Framework.where("LOWER(name) = LOWER(?) AND provider_id = ?", faf[:name].strip, faf[:provider_id])

          if records.exists?
            records.each do |record|
              new_status = determine_new_status(record, faf, records.count)
              update_record(record, faf, new_status)
            end
          else
            record = ::Frameworks::Framework.new(name: faf[:name].strip, provider_id: faf[:provider_id])
            update_record(record, faf, statuses["dfe_approved"])
            record.save!
          end
        end
      end

      # check expired framework
      update_expired_status
      # check archived framework
      update_archive_status(prepared_frameworks)
    end

    def find_framework_by_contentful_id(faf)
      return nil unless faf[:contentful_id].present?

      ::Frameworks::Framework.find_by(contentful_id: faf[:contentful_id])
    end

    def determine_new_status(record, faf, record_count = 1)
      case record.status
      when "dfe_approved"
        get_framework_status(record.status, faf[:provider_end_date])
      when "not_approved"
        record_count > 1 ? statuses["archived"] : statuses["dfe_approved"]
      else
        record.status
      end
    end

    def update_record(record, faf, new_status)
      record.update(
        name: faf[:name].strip,
        contentful_id: faf[:contentful_id],
        faf_slug_ref: faf[:faf_slug_ref],
        faf_category: faf[:faf_category],
        provider_end_date: faf[:provider_end_date],
        url: faf[:url],
        description: faf[:description],
        source: 2,
        status: new_status,
        provider_reference: faf[:provider_reference],
      )
    end

    def prepare_frameworks(frameworks)
      frameworks.select { |framework| framework["expiry"].present? }.map do |framework|
        {
          name: framework["title"],
          contentful_id: framework["id"],
          faf_slug_ref: framework["ref"],
          provider_id: existing_provider(framework["provider"].try(:[], "initials"), framework["provider"].try(:[], "title")),
          faf_category: framework["cat"].try(:[], "title"),
          provider_end_date: Date.parse(framework["expiry"]),
          url: framework["url"],
          description: framework["descr"],
          provider_reference: framework["provider_reference"],
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
      provider_detail = ::Frameworks::Provider.find_by("LOWER(short_name) = LOWER(?)", provider_short_name)
      if provider_detail
        if provider_detail.name != provider_name
          provider_detail.update!(name: provider_name) # to update provider name when title is diff
        end
      else
        provider_detail = ::Frameworks::Provider.new(short_name: provider_short_name, name: provider_name)
        provider_detail.save!
      end
      provider_detail.id
    end

    def get_framework_status(status, provider_end_date)
      if status == statuses["expired"] && !expired?(provider_end_date)
        statuses["dfe_approved"]
      elsif status == statuses["archived"]
        statuses["archived"]
      else
        get_expired_status(provider_end_date)
      end
    end

    def update_archive_status(prepared_frameworks)
      cms_frameworks = ::Frameworks::Framework.where(source: 2, faf_archived_at: nil)

      cms_frameworks.each do |cms_framework|
        exists = prepared_frameworks.any? do |faf_framework|
          # Match by contentful_id if available (authoritative)
          if cms_framework.contentful_id.present? && faf_framework[:contentful_id].present?
            cms_framework.contentful_id == faf_framework[:contentful_id]
          else
            # Fall back to name + provider for legacy records
            cms_framework.name.strip.casecmp?(faf_framework[:name].strip) && cms_framework.provider_id == faf_framework[:provider_id]
          end
        end

        next if exists

        cms_framework.update!(
          status: statuses["archived"],
          is_archived: true,
          faf_archived_at: Time.zone.today,
        )
      end
    end

    def update_expired_status
      cms_frameworks = ::Frameworks::Framework.all

      cms_frameworks.each do |cms_framework|
        if expired?(cms_framework.provider_end_date) && cms_framework.status != "archived"
          ::Frameworks::Framework.find_by!(id: cms_framework.id).update!(status: statuses["expired"])
        elsif !expired?(cms_framework.provider_end_date) && cms_framework.status == "expired" && cms_framework.source != "faf_import"
          ::Frameworks::Framework.find_by!(id: cms_framework.id).update!(status: statuses["dfe_approved"])
        end
      end
    end
  end
end
