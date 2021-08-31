module Support
  class BasePresenter < SimpleDelegator
    def created_at
      format_date(super)
    end

    def updated_at
      format_date(super)
    end

    protected

    def format_name(name)
      name.capitalize
    end

    private

    def format_date(date)
      date.strftime("%e %B %Y")
    end
  end
end
