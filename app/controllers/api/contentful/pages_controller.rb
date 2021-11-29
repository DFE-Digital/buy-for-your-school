# frozen_string_literal: true

class Api::Contentful::PagesController < Api::Contentful::BaseController
  def create
    if page
      render json: { status: "OK" }, status: :ok
      Rollbar.info(
        "Processed published webhook event for Contentful Page",
        page.slice(:title, :slug, :contentful_id),
      )
    end
  end

  def destroy
    Page.find_by(contentful_id: contentful_id).destroy!
    render json: { status: "OK" }, status: :ok
  end

private

  def page
    @page ||= ::Content::Page::Build.new(contentful_page: contentful_page).call
  end

  def contentful_page
    @contentful_page ||= ::Content::Page::Get.new(entry_id: contentful_id).call
  end
end
