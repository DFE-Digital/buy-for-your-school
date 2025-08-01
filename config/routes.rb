# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "specify/create_a_specification#show"

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
    get "create_a_specification", to: "create_a_specification#show"

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
  # Pre-sign-in
  get "/energy/start", to: "energy/onboarding#start", as: "energy_start"
  get "/energy/guidance", to: "energy/onboarding#guidance", as: "energy_guidance"
  get "/energy/before-you-start", to: "energy/onboarding#before_you_start", as: "energy_before_you_start"

  # School selection
  get "/energy/which-school-buying-for", to: "energy/school_selections#show", as: "energy_school_selection"
  patch "/energy/which-school-buying-for", to: "energy/school_selections#update"
  get "/energy/school-selection-unavailable(/:id)", to: "energy/service_availability#show", as: "energy_service_availability"

  # Authorisation
  get "/energy/authorisation/:id/:type", to: "energy/authorisation#show", as: "school_type_energy_authorisation"
  patch "/energy/authorisation/:id/:type", to: "energy/authorisation#update"

  # rubocop:disable Layout/SpaceInsideArrayPercentLiteral
  # Case level
  [
    #  Slug (0)                 Controller (1)                Helper name (2)
    %w[which-energy-supply      switch_energies               energy_case_switch_energy], # FIXME: Should be org level
    %w[gas-contract             gas_suppliers                 energy_case_gas_supplier], # FIXME: Should be org level
    %w[electricity-contract     electric_suppliers            energy_case_electric_supplier], # FIXME: Should be org level
    %w[task-list                tasks                         energy_case_tasks],
    %w[letter-of-authority      letter_of_authorisations      energy_case_letter_of_authorisation],
  ].each do |vals|
    get "/energy/#{vals[0]}/:case_id", to: "energy/#{vals[1]}#show", as: vals[2]
    patch "/energy/#{vals[0]}/:case_id", to: "energy/#{vals[1]}#update"
  end

  get "/energy/check-answers/:case_id", to: "energy/check_your_answers#show", as: "energy_case_check_your_answers"
  get "/energy/information-submitted/:case_id", to: "energy/confirmations#show", as: "energy_case_confirmation"

  # Org level
  [
    #  Slug (0)                 Controller (1)                Helper name (2)
    %w[gas-multi-single         gas_single_multis             energy_case_org_gas_single_multi],
    %w[gas-bill                 gas_bill_consolidations       energy_case_org_gas_bill_consolidation],
    %w[electricity-multi-single electricity_meter_types       energy_case_org_electricity_meter_type],
    %w[electricity-bill         electric_bill_consolidations  energy_case_org_electric_bill_consolidation],
    %w[site-contact             site_contact_details          energy_case_org_site_contact_details],
    %w[vat-rate                 vat_rate_charges              energy_case_org_vat_rate_charge],
    %w[vat-contact              vat_person_responsibles       energy_case_org_vat_person_responsible],
    %w[vat-contact-manual       vat_alt_person_responsibles   energy_case_org_vat_alt_person_responsible],
    %w[vat-certificate          vat_certificates              energy_case_org_vat_certificate],
    %w[billing-preferences      billing_preferences           energy_case_org_billing_preferences],
    %w[billing-address          billing_address_confirmations energy_case_org_billing_address_confirmation],
  ].each do |vals|
    get "/energy/#{vals[0]}/:case_id/:org_id", to: "energy/#{vals[1]}#show", as: vals[2]
    patch "/energy/#{vals[0]}/:case_id/:org_id", to: "energy/#{vals[1]}#update"
  end

  # Meter level
  [
    #  Slug (0)          ID name (1) Controller (2)    Helper name root (3)
    %w[gas-meter         mprn        gas_meter         gas_meter],
    %w[electricity-meter mpan        electricity_meter electricity_meter],
  ].each do |vals|
    get "/energy/#{vals[0]}/:case_id/:org_id", to: "energy/#{vals[2]}#new", as: "new_energy_case_org_#{vals[3]}"
    get "/energy/#{vals[0]}-summary/:case_id/:org_id", to: "energy/#{vals[2]}#index", as: "energy_case_org_#{vals[3]}_index"
    post "/energy/#{vals[0]}-summary/:case_id/:org_id", to: "energy/#{vals[2]}#create" # FIXME: -summary?
    get "/energy/#{vals[0]}/:case_id/:org_id/:id", to: "energy/#{vals[2]}#edit", as: "edit_energy_case_org_#{vals[3]}"
    patch "/energy/#{vals[0]}/:case_id/:org_id/:id", to: "energy/#{vals[2]}#update", as: "energy_case_org_#{vals[3]}"
    delete "/energy/remove-#{vals[1]}/:case_id/:org_id/:id", to: "energy/#{vals[2]}#destroy", as: "delete_energy_case_org_#{vals[3]}"
  end
  # rubocop:enable Layout/SpaceInsideArrayPercentLiteral

  # Cec
  namespace :cec do
    root to: "onboarding_cases#index"
    resources :onboarding_cases, only: %i[index show]
    get "cases/find-a-case/new", to: "/support/cases/searches#new", as: :case_search_new
    get "cases/find-a-case", to: "/support/cases/searches#index", as: :case_search_index

    get "notifications", to: "/support/notifications#index", as: :notifications
    post "notifications/mark_all_read", to: "/support/notifications/mark_all_reads#create", as: :notifications_mark_all_read
    post "notifications/:notification_id/read", to: "/support/notifications/reads#create", as: :notification_read
    delete "notifications/:notification_id/read", to: "/support/notifications/reads#destroy", as: :destroy_notification_read
    post "management/agents", to: "/support/management/agents#create", as: :management_agents
    patch "management/agents/:id", to: "/support/management/agents#update", as: :management_agent
    patch "email_read_status/:email_id", to: "/support/email_read_status#update", as: :email_read_status
    post "management/email_templates", to: "/support/management/email_templates#create", as: :management_email_templates
    get "management/email_templates", to: "/support/management/email_templates#index", as: :management_email_templates_index
    get "management/email_templates/new", to: "/support/management/email_templates#new", as: :new_management_email_template
    get "management/email_templates/:id/edit", to: "/support/management/email_templates#edit", as: :edit_management_email_template
    patch "management/email_templates/:id", to: "/support/management/email_templates#update", as: :update_management_email_template
    delete "management/email_templates/:id", to: "/support/management/email_templates#destroy", as: :delete_management_email_template
    get "management/email_template_groups/subgroups/(:group_id)", to: "/support/management/email_template_groups#subgroups", as: :subgroups_management_email_template_groups

    resources :cases, only: %i[index show] do
      scope module: :cases do
        get "assignments/new", to: "/support/cases/assignments#new", as: :assignment_new
        post "assignments", to: "/support/cases/assignments#create", as: :assignments
        get "message_threads/:id", to: "/support/cases/message_threads#show", as: :message_thread
        post "message_threads", to: "/support/cases/message_threads#create", as: :message_threads
        get "message_threads", to: "/support/cases/message_threads#index", as: :message_threads_index
        get "message_threads/logged_contacts", to: "/support/cases/message_threads#logged_contacts", as: :logged_contacts
        get "interactions/new", to: "/support/interactions#new", as: :new_interaction
        post "interactions", to: "/support/interactions#create", as: :interactions
        post "on_hold", to: "/support/cases/on_holds#create", as: :on_hold
        post "opening", to: "/support/cases/openings#create", as: :opening
        get "opening/new", to: "/support/cases/openings#new", as: :new_opening
        get "resolution/new", to: "/support/cases/resolutions#new", as: :new_resolution
        post "resolution", to: "/support/cases/resolutions#create", as: :resolution
        get "closures", to: "/support/cases/closures#index", as: :closures
        post "closures/confirm", to: "/support/cases/closures#confirm", as: :closures_confirm
        post "closures", to: "/support/cases/closures#create", as: :closures_post
      end
    end

    resources :cases, only: %i[index show] do
      scope module: :cases do
        get "summary/edit", to: "/support/cases/summaries#edit", as: :edit_summary
        patch "summary", to: "/support/cases/summaries#update", as: :update_summary
      end
    end

    resources :cases, only: %i[index show] do
      scope module: :cases do
        get "quick_edit/edit", to: "/support/cases/quick_edits#edit", as: :edit_quick_edit
        patch "quick_edit", to: "/support/cases/quick_edits#update", as: :quick_edit
      end
    end

    namespace :management do
      get "/", to: "base#index"
      resources :agents, only: %i[index edit update new create]
    end
  end

  # Routes any/all Contentful Pages that are mirrored in t.pages
  get ":slug", to: "pages#show"
end
