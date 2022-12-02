module FrameworkRequests
  class BillUploadsController < BaseController
    skip_before_action :authenticate_user!

    def upload
      uploaded_io = params[:file]

      File.open(Rails.root.join('tmp', 'uploads', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end

      head :ok
    end

  private

    def form
      @form ||= FrameworkRequests::BillUploadsForm.new(all_form_params)
    end

    def update_data
      {}
    end

    def create_redirect_path
      message_framework_requests_path(framework_support_form: form.common)
    end

    def back_url
      @back_url = email_framework_requests_path(framework_support_form: form.common)
    end
  end
end
