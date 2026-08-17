class ContentfulWebhooksController < Fabs::ApplicationController
  skip_before_action :verify_authenticity_token

  UPSERT_TOPICS = [
    "ContentManagement.Entry.publish",
  ].freeze

  DELETE_TOPICS = [
    "ContentManagement.Entry.unpublish",
    "ContentManagement.Entry.archive",
    "ContentManagement.Entry.delete",
  ].freeze

  def create
    return head :unauthorized unless valid_signature?

    return render json: { error: "The entry id is missing from the request." }, status: :bad_request if id.blank?

    case topic
    when *UPSERT_TOPICS
      process_upsert
    when *DELETE_TOPICS
      process_delete
    else
      render json: { message: "Ignoring unsupported webhook topic #{topic} for entry #{id}." }, status: :ok
    end
  end

private

  def id
    params.dig("sys", "id")
  end

  def content_type
    params.dig("sys", "contentType", "sys", "id")
  end

  def topic
    request.headers["X-Contentful-Topic"]
  end

  def process_upsert
    case content_type
    when "solution"
      process_solution_index_upsert
    when "redirect"
      invalidate_redirect_cache("processed")
    else
      render json: { message: "Ignoring unsupported content type #{content_type} for entry #{id}." }, status: :ok
    end
  end

  def process_delete
    case content_type
    when "solution"
      process_solution_index_delete
    when "redirect"
      invalidate_redirect_cache("deletion processed")
    else
      render json: { message: "Ignoring unsupported content type #{content_type} for entry #{id}." }, status: :ok
    end
  end

  def process_solution_index_upsert
    result = index_document(id:)

    if result
      render json: { message: "Webhook for entry #{id} processed successfully." }, status: :ok
    else
      render json: { error: "Failed to index the document for id #{id}." }, status: :unprocessable_content
    end
  end

  def process_solution_index_delete
    result = delete_document(id:)

    if result
      render json: { message: "Webhook for entry #{id} deletion processed successfully." }, status: :ok
    else
      render json: { error: "Failed to delete the document for id #{id}." }, status: :unprocessable_content
    end
  end

  def invalidate_redirect_cache(message_suffix)
    RedirectMatcher.invalidate_cache!
    render json: { message: "Webhook for redirect entry #{id} #{message_suffix} successfully." }, status: :ok
  end

  def valid_signature?
    secret == signature
  end

  def secret
    ENV.fetch("CONTENTFUL_WEBHOOK_SECRET")
  end

  def signature
    request.headers["X-Contentful-Webhook-Signature"]
  end

  def index_document(id:)
    if Flipper.enabled?(:azure_ai_search)
      AzureAiSearch::SolutionIndexer.new.index_document(id)
    else
      SolutionIndexer.new(id:).index_document
    end
  end

  def delete_document(id:)
    if Flipper.enabled?(:azure_ai_search)
      AzureAiSearch::SolutionIndexer.new.delete_document(id)
    else
      SolutionIndexer.new(id:).delete_document
    end
  end
end
