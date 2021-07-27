class CategoriesController < ApplicationController
  def index
    @categories = Category.where.not(contentful_id: 0).order(:title)
  end
end
