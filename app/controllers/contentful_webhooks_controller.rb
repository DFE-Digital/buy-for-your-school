class ContentfulWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    unless valid_signature?
      Rollbar.error("Contentful webhook signature validation failed", {
        headers: request.headers.to_h.select { |k, _| k.start_with?("X-Contentful") },
        has_secret: secret.present?
      })
      return head :unauthorized
    end

    if id.present?
      result = SolutionIndexer.new(id: id).index_document

      if result
        render json: { message: "Webhook for entry #{id} processed successfully." }, status: :ok
      else
        Rollbar.error("Failed to index document in OpenSearch", {
          entry_id: id,
          webhook_topic: request.headers["X-Contentful-Topic"],
          webhook_name: request.headers["X-Contentful-Webhook-Name"]
        })
        render json: { error: "Failed to index the document for id #{id}." }, status: :unprocessable_content
      end
    else
      body_data = begin
        JSON.parse(request.raw_post) if request.raw_post.present?
      rescue JSON::ParserError
        nil
      end
      Rollbar.error("Contentful webhook missing entityId", {
        params_keys: params.keys,
        sys_id: params.dig("sys", "id"),
        webhook_topic: request.headers["X-Contentful-Topic"],
        webhook_name: request.headers["X-Contentful-Webhook-Name"],
        request_body_keys: body_data&.keys || []
      })
      render json: { error: "The 'entityId' is missing from the request." }, status: :bad_request
    end
  rescue JSON::ParserError => e
    Rollbar.error("Contentful webhook JSON parse error", {
      error: e.message,
      entry_id: id,
      webhook_topic: request.headers["X-Contentful-Topic"]
    })
    render json: { error: "Invalid request format." }, status: :bad_request
  rescue StandardError => e
    Rollbar.error(e, {
      entry_id: id,
      webhook_topic: request.headers["X-Contentful-Topic"],
      action: "create"
    })
    render json: { error: "Internal server error processing webhook." }, status: :internal_server_error
  end

  def destroy
    unless valid_signature?
      Rollbar.error("Contentful webhook signature validation failed (delete)", {
        headers: request.headers.to_h.select { |k, _| k.start_with?("X-Contentful") },
        has_secret: secret.present?
      })
      return head :unauthorized
    end

    if id.present?
      result = SolutionIndexer.new(id: id).delete_document

      if result
        render json: { message: "Webhook for entry #{id} deletion processed successfully." }, status: :ok
      else
        Rollbar.error("Failed to delete document from OpenSearch", {
          entry_id: id,
          webhook_topic: request.headers["X-Contentful-Topic"],
          webhook_name: request.headers["X-Contentful-Webhook-Name"]
        })
        render json: { error: "Failed to delete the document for id #{id}." }, status: :unprocessable_content
      end
    else
      Rollbar.error("Contentful webhook missing entityId (delete)", {
        params_keys: params.keys,
        sys_id: params.dig("sys", "id"),
        webhook_topic: request.headers["X-Contentful-Topic"]
      })
      render json: { error: "The 'entityId' is missing from the request." }, status: :bad_request
    end
  rescue StandardError => e
    Rollbar.error(e, {
      entry_id: id,
      webhook_topic: request.headers["X-Contentful-Topic"],
      action: "destroy"
    })
    render json: { error: "Internal server error processing webhook." }, status: :internal_server_error
  end

private

  def id
    params.dig("sys", "id") || params.dig(:sys, :id) || params["entityId"]
  end

  def valid_signature?
    secret == signature
  end

  def secret
    ENV["CONTENTFUL_WEBHOOK_SECRET"]
  end

  def signature
    request.headers["X-Contentful-Webhook-Signature"]
  end
end
