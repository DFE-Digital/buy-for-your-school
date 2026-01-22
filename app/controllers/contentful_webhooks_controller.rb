class ContentfulWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    return head :unauthorized unless valid_signature?

    if id.present?
      result = SolutionIndexer.new(id: id).index_document

      if result
        render json: { message: "Webhook for entry #{id} processed successfully." }, status: :ok
      else
        render json: { error: "Failed to index the document for id #{id}." }, status: :unprocessable_content
      end
    else
      render json: { error: "The 'entityId' is missing from the request." }, status: :bad_request
    end
  end

  def destroy
    return head :unauthorized unless valid_signature?

    if id.present?
      result = SolutionIndexer.new(id: id).delete_document

      if result
        render json: { message: "Webhook for entry #{id} deletion processed successfully." }, status: :ok
      else
        render json: { error: "Failed to delete the document for id #{id}." }, status: :unprocessable_content
      end
    else
      render json: { error: "The 'entityId' is missing from the request." }, status: :bad_request
    end
  end

private

  def id
    params["entityId"]
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
