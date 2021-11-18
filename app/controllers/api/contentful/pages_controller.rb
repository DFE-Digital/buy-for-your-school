# frozen_string_literal: true

class Api::Contentful::PagesController < Api::Contentful::BaseController
  def create
    # TODO: awaiting services/contentful/page/*.rb get/build code
    page = Page.upsert(
      {
        title: params[:sys][:title],
        body: nil,
        contentful_id: contentful_id,
        slug: params[:sys][:slug],
      },
      unique_by: :contentful_id
    )

    if page.first
      render json: { status: "OK" }, status: :ok
      Rollbar.info("Processed published webhook event for Contentful Page", **page.first)
    end
  end

  def destroy
    Page.find_by(contentful_id: contentful_id).destroy
    render json: { status: "OK" }, status: :ok
  end

private

  def page_params
    params.require(:sys).permit(:id)
  end
end
