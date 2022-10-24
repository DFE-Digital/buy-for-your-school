class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  STATIC_PAGES = %w[
    energy-bill-relief-scheme
    rising-energy-prices
  ].freeze

  def show
    if STATIC_PAGES.include?(params[:page])
      render params[:page]
    else
      render "errors/not_found"
    end
  end
end
