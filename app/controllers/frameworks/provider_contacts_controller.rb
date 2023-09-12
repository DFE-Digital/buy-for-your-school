class Frameworks::ProviderContactsController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :set_back_url, only: %i[show edit]

  def index
    @filtering = Frameworks::ProviderContact.filtering(filter_form_params)
    @provider_contacts = @filtering.results.paginate(page: params[:provider_contacts_page])
  end

  def show
    @provider_contact = Frameworks::ProviderContact.find(params[:id])
  end

  def edit
    @provider_contact = Frameworks::ProviderContact.find(params[:id])
  end

  def update
    @provider_contact = Frameworks::ProviderContact.find(params[:id])

    if @provider_contact.update(provider_contact_params)
      redirect_to frameworks_provider_contact_path(@provider_contact)
    else
      render :edit
    end
  end

private

  def set_back_url
    @back_url = back_link_param
  end

  def filter_form_params
    params.fetch(:provider_contacts_filter, {}).permit(:sort_by, :sort_order, provider: [])
  end

  def provider_contact_params
    params.require(:frameworks_provider_contact).permit(:name, :email, :phone)
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "provider-contacts", **request.params.except(:controller, :action))
  end
end
