class Frameworks::ProviderContactsController < Frameworks::ApplicationController
  before_action :redirect_to_register_tab, unless: :turbo_frame_request?, only: :index
  before_action :load_form_options, only: %i[new edit update create]

  def index
    @filtering = Frameworks::ProviderContact.filtering(filter_form_params)
    @provider_contacts = @filtering.results.paginate(page: params[:provider_contacts_page])
  end

  def show
    @provider_contact = Frameworks::ProviderContact.find(params[:id])
    @activity_log_items = @provider_contact.activity_log_items.paginate(page: params[:activities_page])
  end

  def new
    @provider_contact = Frameworks::ProviderContact.new
  end

  def edit
    @provider_contact = Frameworks::ProviderContact.find(params[:id])
  end

  def create
    @provider_contact = Frameworks::ProviderContact.new(provider_contact_params)

    if @provider_contact.save
      redirect_to frameworks_provider_contact_path(@provider_contact)
    else
      render :new
    end
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

  def load_form_options
    @providers = Frameworks::Provider.all
  end

  def filter_form_params
    params.fetch(:provider_contacts_filter, {}).permit(:sort_by, :sort_order, provider: [])
  end

  def provider_contact_params
    params.require(:frameworks_provider_contact).permit(:name, :email, :phone, :provider_id)
  end

  def redirect_to_register_tab
    redirect_to frameworks_root_path(anchor: "provider-contacts", **request.params.except(:controller, :action))
  end
end
