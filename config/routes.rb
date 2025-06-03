# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "specify/home#show"

  # Misc
  get "health_check" => "application#health_check"
  get "maintenance" => "application#maintenance"
  resource :cookie_preferences, only: %i[show edit update]
  resources :design, only: %i[index show]
  get "/pages/:page", to: "static_pages#show"

  # CMS entrypoints
  get "cms", to: "cms_entry_points#start", as: :cms_entrypoint
  get "cms/no_roles_assigned", to: "cms_entry_points#no_roles_assigned", as: :cms_no_roles_assigned
  get "cms/not_authorized", to: "cms_entry_points#not_authorized", as: :cms_not_authorized

  # DfE Sign In
  get "/auth/dfe/callback", to: "sessions#create", as: :sign_in
  get "/auth/dfe/signout", to: "sessions#destroy", as: :issuer_redirect
  delete "/auth/dfe/signout", to: "sessions#destroy", as: :sign_out
  get "/auth/failure", to: "sessions#failure"
  post "/auth/developer/callback" => "sessions#bypass_callback" if Rails.env.development?

  # Errors
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_server_error"

  # "Legacy" admin
  scope "/admin", as: "admin" do
    get "/", to: "admin#show"
    scope "/download", as: "download" do
      get "user_activity", to: "admin#download_user_activity", as: "user_activity"
      get "users", to: "admin#download_users", as: "users"
    end
  end

  # Referrals
  namespace :referrals do
    get "/rfh/:referral_path", to: "referrals#rfh"
    get "/specify/:referral_path", to: "referrals#specify"
    get "/faf/:referral_path", to: "referrals#faf"
  end

  # Contentful
  namespace :api do
    namespace :contentful do
      post "auth" => "base#auth"
      post "entry_updated" => "entries#changed"
      post "category" => "categories#changed"
      resources :pages, only: %i[create destroy]
    end

    namespace :find_a_framework do
      post "framework" => "frameworks#changed"
    end

    namespace :user_journeys do
      post "step" => "step#create"
    end
  end

  # Specify
  scope module: :specify do
    get "dashboard", to: "dashboard#show"

    resources :feedback, only: %i[new show create edit update]
    get "profile", to: "profile#show"

    resources :support_requests, except: %i[destroy], path: "support-requests"
    resources :support_request_submissions, only: %i[update show], path: "support-request-submissions"
    post "/submit", to: "api/support/requests#create", as: :submit_request

    # NB: guard against use of back button after form validation errors
    get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")
    resources :journeys, only: %i[new show create destroy edit update] do
      resource :specification, only: %i[create show] do
        get :download, to: "specifications#new"
      end
      resources :steps, only: %i[new show edit update] do
        resources :answers, only: %i[create update]
      end
      resources :tasks, only: [:show]
    end

    namespace :preview do
      resources :entries, only: [:show]
    end
  end

  # Request for help
  scope module: "framework_requests" do
    resources :framework_requests, only: %i[index show], path: "procurement-support" do
      collection do
        post "/start", to: "start#create"

        get "/energy_bill", to: "energy_bills#index"
        post "/energy_bill", to: "energy_bills#create"

        get "/energy_alternative", to: "energy_alternatives#index"
        post "/energy_alternative", to: "energy_alternatives#create"

        get "/sign_in", to: "sign_in#index"
        post "/sign_in", to: "sign_in#create"

        get "/confirm_sign_in", to: "confirm_sign_in#index"
        post "/confirm_sign_in", to: "confirm_sign_in#create"

        get "/select_organisation", to: "select_organisations#index"
        post "/select_organisation", to: "select_organisations#create"

        get "/organisation_type", to: "organisation_types#index"
        post "/organisation_type", to: "organisation_types#create"

        get "/search_for_organisation", to: "search_for_organisations#index"
        post "/search_for_organisation", to: "search_for_organisations#create"

        get "/confirm_organisation", to: "confirm_organisations#index"
        post "/confirm_organisation", to: "confirm_organisations#create"

        get "/school_picker", to: "school_pickers#index"
        post "/school_picker", to: "school_pickers#create"

        get "/confirm_schools", to: "confirm_schools#index"
        post "/confirm_schools", to: "confirm_schools#create"

        get "/name", to: "names#index"
        post "/name", to: "names#create"

        get "/email", to: "emails#index"
        post "/email", to: "emails#create"

        get "/bill_uploads", to: "bill_uploads#index"
        post "/bill_uploads", to: "bill_uploads#create"
        get "(:id)/bill_uploads/list", to: "bill_uploads#list", as: "list_bill_uploads"
        post "(:id)/bill_uploads/upload", to: "bill_uploads#upload", as: "upload_bill_uploads"
        delete "(:id)/bill_uploads/remove", to: "bill_uploads#remove", as: "remove_bill_uploads"

        get "/message", to: "messages#index"
        post "/message", to: "messages#create"

        get "/categories/(*category_path)", to: "categories#index", as: "categories"
        post "/categories/(*category_path)", to: "categories#create"

        get "/contract_length", to: "contract_lengths#index"
        post "/contract_length", to: "contract_lengths#create"

        get "/contract_start_date", to: "contract_start_dates#index"
        post "/contract_start_date", to: "contract_start_dates#create"

        get "/same_supplier", to: "same_suppliers#index"
        post "/same_supplier", to: "same_suppliers#create"

        get "/procurement_amount", to: "procurement_amounts#index"
        post "/procurement_amount", to: "procurement_amounts#create"

        get "/documents", to: "documents#index"
        post "/documents", to: "documents#create"

        get "/document_uploads", to: "document_uploads#index"
        post "/document_uploads", to: "document_uploads#create"
        get "(:id)/document_uploads/list", to: "document_uploads#list", as: "list_document_uploads"
        post "(:id)/document_uploads/upload", to: "document_uploads#upload", as: "upload_document_uploads"
        delete "(:id)/document_uploads/remove", to: "document_uploads#remove", as: "remove_document_uploads"

        get "/special_requirements", to: "special_requirements#index"
        post "/special_requirements", to: "special_requirements#create"

        get "/origin", to: "origins#index"
        post "/origin", to: "origins#create"
      end
      member do
        resource :select_organisation, only: %i[edit update], as: :framework_request_select_organisation
        resource :organisation_type, only: %i[edit update], as: :framework_request_organisation_type
        resource :search_for_organisation, only: %i[edit update], as: :framework_request_search_for_organisation
        resource :confirm_organisation, only: %i[edit update], as: :framework_request_confirm_organisation
        resource :school_picker, only: %i[edit update], as: :framework_request_school_picker
        resource :confirm_schools, only: %i[edit update], as: :framework_request_confirm_schools
        resource :name, only: %i[edit update], as: :framework_request_name
        resource :email, only: %i[edit update], as: :framework_request_email
        resource :energy_bill, only: %i[edit update], as: :framework_request_energy_bill
        resource :energy_alternative, only: %i[edit update], as: :framework_request_energy_alternative
        resource :bill_uploads, only: %i[edit update], as: :framework_request_bill_uploads
        resource :message, only: %i[edit update], as: :framework_request_message
        resource :category, only: [], as: :framework_request_category do
          get "edit/(*category_path)", to: "categories#edit", as: "edit"
          patch "(*category_path)", to: "categories#update", as: ""
        end
        resource :contract_length, only: %i[edit update], as: :framework_request_contract_length
        resource :contract_start_date, only: %i[edit update], as: :framework_request_contract_start_date
        resource :same_supplier, only: %i[edit update], as: :framework_request_same_supplier
        resource :procurement_amount, only: %i[edit update], as: :framework_request_procurement_amount
        resource :documents, only: %i[edit update], as: :framework_request_documents
        resource :document_uploads, only: %i[edit update], as: :framework_request_document_uploads
        resource :special_requirements, only: %i[edit update], as: :framework_request_special_requirements
        resource :origin, only: %i[edit update], as: :framework_request_origin
      end
    end
    resources :framework_request_submissions, only: %i[update show], path: "procurement-support-submissions"
  end

  # Proc-Ops Portal
  namespace :support do
    root to: "cases#index"

    resources :document_downloads, only: %i[show update]
    resources :agents, only: %i[create]
    resources :email_read_status, only: %i[update], param: :email_id
    resources :organisations, only: %i[index]
    resources :establishments, only: %i[index]
    get "establishments/list_for_non_participating_establishment", as: :list_for_non_participating_establishment
    resources :establishment_groups, only: %i[index]
    resources :frameworks, only: %i[index]
    resources :towers, only: [:show]
    resources :cases, only: %i[index show] do
      resources :interactions, only: %i[new create show]
      scope module: :cases do
        collection do
          resources :searches, only: %i[new index], as: :case_search, path: "find-a-case"
        end
        resources :attachments, only: %i[index edit update destroy]
        resources :files
        resource :organisation, only: %i[edit update]
        resources :confirm_organisation, only: %i[show update]
        resource :contact_details, only: %i[edit update]
        resource :savings, only: %i[edit update]
        resource :procurement_details, only: %i[edit update]
        resources :documents, only: %i[show]
        resource :resolution, only: %i[new create]
        resources :assignments, only: %i[new create index]
        resource :opening, only: %i[new create]
        resource :on_hold, only: %i[create]
        resource :summary, only: %i[edit update]
        resources :contracts, only: %i[edit update]
        resources :additional_contacts
        resources :evaluators, except: %i[show]
        resource :evaluation_due_dates, only: %i[edit update]
        resource :document_uploads, except: %i[show]
        resource :email_evaluators, except: %i[show]
        resource :review_evaluation, except: %i[show]
        resources :contract_recipients, except: %i[show]
        resource :upload_contract_handover, except: %i[show]
        resources :share_handover_packs, except: %i[show]
        resource :email, only: %i[create] do
          scope module: :emails do
            resources :content, only: %i[show], param: :template
            # resources :templates, only: %i[index], param: :template
          end
        end
        resources :message_threads, only: %i[index show create edit] do
          scope do
            collection do
              get "templated_messages"
              get "logged_contacts"
            end
            post "submit", on: :member
          end
        end
        resources :messages, only: %i[create] do
          scope module: :messages do
            resources :replies, only: %i[create edit] do
              post "submit", on: :member
            end
          end
        end
        resources :email_templates, only: %i[index]
        resource :quick_edit, only: %i[edit update]
        resource :school_details, only: %i[show] do
          scope module: :school_details do
            resource :participating_schools, only: %i[show edit update]
            resource :other_schools do
              get :non_beneficiery_schools
              get :other_school
              get :confirmation_message
              patch :add_other_school
              patch :remove_school
            end
          end
        end
        resource :request_details, only: %i[show] do
          scope module: :request_details do
            resource :participating_schools, only: %i[show]
          end
        end
        resource :tasklist, only: %i[show]
        get :transfer_to_framework_evaluation, to: "transfer_to_framework_evaluation#index"
        post :transfer_to_framework_evaluation, to: "transfer_to_framework_evaluation#create"
        get "move_emails/", to: "move_emails#index", as: "move_emails"
        post "move_emails/", to: "move_emails#create", as: nil
        post "move_emails/confirm", to: "move_emails#confirm", as: "move_emails_confirm"
        get "closures/", to: "closures#index", as: "closures"
        post "closures/", to: "closures#create", as: "support_case_closures"
        post "closures/confirm", to: "closures#confirm", as: "closures_confirm"
        resource :onboarding_summary, only: %i[show]
      end
    end

    resources :case_requests, only: %i[create edit update show] do
      post "/submit", to: "case_requests#submit", on: :member

      scope module: "case_requests" do
        member do
          resource :school_picker, only: %i[edit update], as: :case_request_school_picker
        end
      end
    end

    resources :notifications, only: :index do
      scope module: :notifications do
        resource :read, only: %i[create destroy]

        collection do
          resource :mark_all_read, only: %i[create], as: :notifications_mark_all_read
        end
      end
    end

    resources :messages do
      resource :save_attachments, only: %i[new create]
    end

    resource :case_statistics, only: :show do
      scope module: :case_statistics do
        resources :towers, only: :show
      end
    end

    namespace :management do
      get "/", to: "base#index"
      resources :agents, only: %i[index edit update new create]
      resources :categories, only: %i[index update]
      resources :email_templates do
        get "/attachment-list", to: "email_templates#attachment_list", on: :member
      end
      resources :email_template_groups, only: [] do
        get "subgroups/(:group_id)", to: "email_template_groups#subgroups", as: :subgroups, on: :collection
      end
      resource :category_detection, only: %i[new create]
      resources :all_cases_surveys, only: %i[index create]
      resources :sync_frameworks, only: %i[index create]
    end
  end

  namespace :evaluation do
    resources :download_documents, only: %i[show update]
    resources :upload_completed_documents, except: %i[new], param: :case_id
    resources :tasks, only: %i[show edit]
    resources :signin, only: %i[show edit]
    resources :evaluation_approved, only: %i[show]
    get "verify/evaluator/link/:id", to: "tasks#edit", as: :verify_evaluators_unique_link
  end

  namespace :my_procurements do
    resources :download_handover_packs, only: %i[show update]
    resources :tasks, only: %i[show edit]
    resources :signin, only: %i[show edit]
    get "verify/link/:id", to: "tasks#edit", as: :verify_unique_link
  end

  # E&O Portal
  namespace :engagement do
    root to: "cases#index"
    resources :cases, only: %i[index show] do
      scope module: :cases do
        collection do
          post "uploads/(:upload_reference)/add", to: "uploads#upload", as: "add_uploads"
          delete "uploads/(:upload_reference)/remove", to: "uploads#remove", as: "remove_uploads"
          get "uploads/(:upload_reference)/list", to: "uploads#list", as: "list_uploads"
        end
      end
    end

    resources :case_requests, only: %i[create edit update show] do
      post "/submit", to: "case_requests#submit", on: :member

      scope module: "case_requests" do
        member do
          resource :school_picker, only: %i[edit update], as: :case_request_school_picker
          resource :contract_start_date, only: %i[edit update], as: :case_request_contract_start_date
          resource :same_supplier, only: %i[edit update], as: :case_request_same_supplier
        end
      end
    end

    namespace :management do
      get "/", to: "base#index"
      resources :agents, only: %i[index edit update new create]
    end
  end

  # Frameworks portal
  namespace :frameworks do
    root to: "dashboards#index"

    resources :evaluations do
      scope module: :evaluations do
        resource :contacts, only: %i[edit update]
        resource :quick_edit, only: %i[edit update]
      end
    end
    resources :frameworks do
      resource :categorisations, only: %i[edit update], controller: :framework_categorisations
    end
    resources :providers
    resources :provider_contacts

    namespace :management do
      get "/", to: "management#index"
      resource :register_upload, only: %i[new create]
      resource :activity_log, only: %i[show]
    end
  end

  resources :tickets, only: %i[index]
  scope module: :tickets do
    resource :messages, path: "/messages/:message_id", only: %i[update destroy] do
      get "/attachments", to: "messages#list_attachments", on: :member
      post "/attachments", to: "messages#add_attachment", on: :member
      delete "/attachments/remove", to: "messages#remove_attachment", on: :member
    end
    resources :message_replies, path: "/messages/:message_id/replies", only: %i[create edit] do
      post "submit", on: :member
    end
    resources :message_threads, path: "/tickets/:ticket_id/threads", only: %i[index show create edit] do
      post "submit", on: :member
    end
    resources :message_attachments, path: "/tickets/:ticket_id/attachments", only: %i[index edit update destroy]
    resources :attach_email_attachments, path: "/messages/:message_id/attach_email_attachments", only: %i[index create]
    resources :attach_case_files, path: "/messages/:message_id/attach_case_files", only: %i[index create]
  end

  namespace :exit_survey do
    resources :start, only: %i[show]
    resources :satisfaction, only: %i[edit update]
    resources :satisfaction_reason, only: %i[edit update]
    resources :saved_time, only: %i[edit update]
    resources :better_quality, only: %i[edit update]
    resources :future_support, only: %i[edit update]
    resources :hear_about_service, only: %i[edit update]
    resources :opt_in, only: %i[edit update]
    resources :opt_in_detail, only: %i[edit update]
    resources :thank_you, only: %i[show]
  end

  namespace :all_cases_survey do
    resources :start, only: %i[show]
    resources :satisfaction, only: %i[edit update]
    resources :satisfaction_reason, only: %i[edit update]
    resources :outcome_achieved, only: %i[edit update]
    resources :about_outcomes, only: %i[edit update]
    resources :improvements, only: %i[edit update]
    resources :accessibility_research, only: %i[edit update]
    resources :thank_you, only: %i[show]
  end

  resources :customer_satisfaction_surveys, only: %i[new create] do
    scope module: :customer_satisfaction_surveys, as: :customer_satisfaction_surveys do
      member do
        resource :satisfaction_level, only: %i[edit update]
        resource :satisfaction_reason, only: %i[edit update]
        resource :easy_to_use_rating, only: %i[edit update]
        resource :helped_how, only: %i[edit update]
        resource :clear_to_use_rating, only: %i[edit update]
        resource :recommendation_likelihood, only: %i[edit update]
        resource :improvements, only: %i[edit update]
        resource :research_opt_in, only: %i[edit update]
      end
      collection do
        resource :thank_you, only: %i[show]
      end
    end
  end

  resources :end_of_journey_surveys, only: %i[new create] do
    scope module: :end_of_journey_surveys, as: :end_of_journey_surveys do
      collection do
        resource :thank_you, only: %i[show]
      end
    end
  end

  resources :usability_surveys, only: %i[new create]

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web, at: "/sidekiq"
  end

  flipper_app = Flipper::UI.app do |builder|
    if Rails.env.production?
      builder.use Rack::Auth::Basic do |username, password|
        username == ENV["FLIPPER_USERNAME"] && password == ENV["FLIPPER_PASSWORD"]
      end
    end
  end
  mount flipper_app, at: "/flipper"

  # Energy
  namespace :energy do
    get "/onboarding(/:step)", to: "onboarding#show", as: "onboarding"
    post "/onboarding/:step", to: "onboarding#update", as: "update_onboarding"
    get "/service_availability(/:id)", to: "service_availability#show", as: "service_availability"
    resource :school_selection, only: %i[show update]
    resources :authorisation, only: %i[show update] do
      member do
        get ":type", to: "authorisation#show", as: :school_type
        patch ":type", to: "authorisation#update"
      end
    end
    resources :case, only: %i[show] do
      resource :switch_energy, only: %i[show update]
      resource :gas_supplier, only: %i[show update]
      resource :electric_supplier, only: %i[show update]
      resource :tasks, only: %i[show update]
      resource :letter_of_authorisation, only: %i[show update]
      resource :confirmation, only: :show

      resources :org, except: %i[show] do
        resources :gas_meter, except: %i[show]
        resource :gas_bill_consolidation, only: %i[show update]
        resource :electric_bill_consolidation, only: %i[show update]
        resource :electricity_meter_type, only: %i[show update]
        resource :gas_single_multi, only: %i[show update]
        resources :electricity_meter, except: %i[show]
        resource :vat_rate_charge, only: %i[show update]
        resource :site_contact_details, only: %i[show update]
        resource :vat_person_responsible, only: %i[show update]
        resource :vat_alt_person_responsible, only: %i[show update]
        resource :vat_certificate, only: %i[show update]
        resource :billing_preferences, only: %i[show update]
        resource :billing_address_confirmation, only: %i[show update]
      end
    end
  end

  # Cec
  namespace :cec do
    root to: "onboarding_cases#index"
    resources :onboarding_cases, only: %i[index show]

    namespace :management do
      get "/", to: "base#index"
      resources :agents, only: %i[index edit update new create]
    end
  end

  # Routes any/all Contentful Pages that are mirrored in t.pages
  get ":slug", to: "pages#show"
end
