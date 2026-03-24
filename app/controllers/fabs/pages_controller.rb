class Fabs::PagesController < Fabs::ApplicationController
  def show
    @page = FABS::Page.find_by_slug!(params[:slug])
    @page_title = @page.title
    add_breadcrumb home_breadcrumb_name, home_breadcrumb_path
    build_page_breadcrumbs(@page)

    render layout: "fabs_application"
  end

private

  def build_page_breadcrumbs(page)
    node = page.parent
    trail = []
    max_depth = 4

    max_depth.times do
      break unless node

      trail << node

      case node
      when FABS::Category
        @category = node
        break
      when FABS::Page
        node = node.parent
      else
        break
      end
    end

    trail.reverse_each do |n|
      case n
      when FABS::Category
        add_breadcrumb category_breadcrumb_name, category_breadcrumb_path
      when FABS::Page
        add_breadcrumb n.title, page_path(n.slug)
      end
    end
  end
end
