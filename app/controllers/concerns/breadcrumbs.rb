module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    def home_breadcrumb_name
      "Home"
    end
    helper_method :home_breadcrumb_name

    def home_breadcrumb_path
      root_path
    end
    helper_method :home_breadcrumb_path

    def category_breadcrumb_name
      @category&.title
    end
    helper_method :category_breadcrumb_name

    def category_breadcrumb_path
      category_path(slug: @category&.slug)
    end
    helper_method :category_breadcrumb_path

    def primary_category_breadcrumb_name
      @primary_category&.title
    end
    helper_method :primary_category_breadcrumb_name

    def primary_category_breadcrumb_path
      category_path(slug: @primary_category&.slug)
    end
    helper_method :primary_category_breadcrumb_path

    def offers_breadcrumb_name
      t("breadcrumbs.offers")
    end
    helper_method :offers_breadcrumb_name

    def offers_breadcrumb_path
      offers_path
    end
    helper_method :offers_breadcrumb_path
  end
end
