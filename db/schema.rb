# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_30_164718) do
  create_sequence "evaluation_refs"
  create_sequence "framework_refs"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_log", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "journey_id"
    t.string "user_id"
    t.string "contentful_category_id"
    t.string "contentful_section_id"
    t.string "contentful_task_id"
    t.string "contentful_step_id"
    t.string "action"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contentful_category"
    t.string "contentful_section"
    t.string "contentful_task"
    t.string "contentful_step"
    t.index ["action"], name: "index_activity_log_on_action"
    t.index ["contentful_category_id"], name: "index_activity_log_on_contentful_category_id"
    t.index ["contentful_section_id"], name: "index_activity_log_on_contentful_section_id"
    t.index ["contentful_step_id"], name: "index_activity_log_on_contentful_step_id"
    t.index ["contentful_task_id"], name: "index_activity_log_on_contentful_task_id"
    t.index ["journey_id"], name: "index_activity_log_on_journey_id"
    t.index ["user_id"], name: "index_activity_log_on_user_id"
  end

  create_table "all_cases_survey_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "case_id"
    t.integer "satisfaction_level"
    t.text "satisfaction_text"
    t.integer "outcome_achieved"
    t.text "about_outcomes_text"
    t.text "improve_text"
    t.integer "status"
    t.string "user_ip"
    t.datetime "survey_started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accessibility_research_opt_in"
    t.string "accessibility_research_email"
    t.datetime "survey_sent_at"
    t.datetime "survey_completed_at"
    t.index ["case_id"], name: "index_all_cases_survey_responses_on_case_id"
  end

  create_table "case_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "extension_number"
    t.text "request_text"
    t.boolean "submitted", default: false
    t.uuid "created_by_id"
    t.uuid "organisation_id"
    t.string "organisation_type"
    t.uuid "category_id"
    t.uuid "query_id"
    t.string "other_category"
    t.string "other_query"
    t.decimal "procurement_amount", precision: 9, scale: 2
    t.string "school_urns", default: [], array: true
    t.integer "discovery_method"
    t.string "discovery_method_other_text"
    t.integer "source"
    t.integer "creation_source"
    t.uuid "support_case_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "same_supplier_used"
    t.boolean "contract_start_date_known"
    t.date "contract_start_date"
    t.index ["category_id"], name: "index_case_requests_on_category_id"
    t.index ["created_by_id"], name: "index_case_requests_on_created_by_id"
    t.index ["query_id"], name: "index_case_requests_on_query_id"
    t.index ["support_case_id"], name: "index_case_requests_on_support_case_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.string "contentful_id", null: false
    t.jsonb "liquid_template", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "journeys_count"
    t.string "slug", null: false
    t.index ["contentful_id"], name: "index_categories_on_contentful_id", unique: true
  end

  create_table "checkbox_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "further_information"
    t.boolean "skipped", default: false
    t.index ["step_id"], name: "index_checkbox_answers_on_step_id"
  end

  create_table "currency_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.decimal "response", precision: 11, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_currency_answers_on_step_id"
  end

  create_table "customer_satisfaction_survey_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "satisfaction_level"
    t.text "satisfaction_text"
    t.integer "easy_to_use_rating"
    t.string "helped_how", default: [], array: true
    t.text "helped_how_other"
    t.integer "clear_to_use_rating"
    t.integer "recommendation_likelihood"
    t.text "improvements"
    t.boolean "research_opt_in"
    t.string "research_opt_in_email"
    t.string "research_opt_in_job_title"
    t.integer "service"
    t.integer "source"
    t.integer "status"
    t.datetime "survey_sent_at"
    t.datetime "survey_started_at"
    t.datetime "survey_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "referer"
    t.uuid "support_case_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "submission_status", default: 0
    t.string "filename"
    t.integer "filesize"
    t.uuid "support_case_id"
    t.uuid "framework_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["framework_request_id"], name: "index_documents_on_framework_request_id"
    t.index ["support_case_id"], name: "index_documents_on_support_case_id"
  end

  create_table "end_of_journey_survey_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "easy_to_use_rating"
    t.text "improvements"
    t.integer "service"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "energy_bills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "submission_status", default: 0
    t.string "filename"
    t.integer "filesize"
    t.uuid "support_case_id"
    t.uuid "framework_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.index ["framework_request_id"], name: "index_energy_bills_on_framework_request_id"
    t.index ["support_case_id"], name: "index_energy_bills_on_support_case_id"
  end

  create_table "energy_electricity_meters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "energy_onboarding_case_organisation_id"
    t.string "mpan", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["energy_onboarding_case_organisation_id"], name: "idx_on_energy_onboarding_case_organisation_id_8c71bc911c"
  end

  create_table "energy_gas_meters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "energy_onboarding_case_organisation_id"
    t.string "mprn", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gas_usage"
    t.index ["energy_onboarding_case_organisation_id"], name: "idx_on_energy_onboarding_case_organisation_id_9ef1acd25b"
  end

  create_table "energy_onboarding_case_organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "energy_onboarding_case_id"
    t.uuid "onboardable_id"
    t.string "onboardable_type"
    t.integer "switching_energy_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gas_current_supplier"
    t.string "gas_current_supplier_other"
    t.date "gas_current_contract_end_date"
    t.integer "electric_current_supplier"
    t.string "electric_current_supplier_other"
    t.date "electric_current_contract_end_date"
    t.index ["energy_onboarding_case_id"], name: "idx_on_energy_onboarding_case_id_a2b87b0066"
    t.index ["onboardable_type", "onboardable_id"], name: "idx_on_onboardable_type_onboardable_id_aa8b300738"
  end

  create_table "energy_onboarding_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.boolean "are_you_authorised"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_case_id"], name: "index_energy_onboarding_cases_on_support_case_id"
  end

  create_table "engagement_case_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "upload_status", default: 0
    t.string "filename"
    t.integer "filesize"
    t.string "upload_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "support_case_id"
    t.uuid "case_request_id"
    t.index ["case_request_id"], name: "index_engagement_case_uploads_on_case_request_id"
  end

  create_table "exit_survey_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "case_id"
    t.integer "satisfaction_level"
    t.string "satisfaction_text"
    t.integer "saved_time"
    t.integer "better_quality"
    t.integer "future_support"
    t.integer "hear_about_service"
    t.boolean "opt_in"
    t.string "opt_in_name"
    t.string "opt_in_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hear_about_service_other"
    t.integer "status"
    t.string "user_ip"
    t.datetime "survey_started_at"
    t.datetime "survey_sent_at"
    t.datetime "survey_completed_at"
    t.index ["case_id"], name: "index_exit_survey_responses_on_case_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "framework_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "message_body"
    t.boolean "submitted", default: false
    t.uuid "user_id"
    t.boolean "group", default: false
    t.string "org_id"
    t.decimal "procurement_amount", precision: 9, scale: 2
    t.integer "confidence_level"
    t.string "special_requirements"
    t.boolean "is_energy_request"
    t.integer "energy_request_about"
    t.boolean "have_energy_bill"
    t.integer "energy_alternative"
    t.uuid "category_id"
    t.text "category_other"
    t.string "school_urns", default: [], array: true
    t.uuid "support_case_id"
    t.integer "contract_length"
    t.boolean "contract_start_date_known"
    t.date "contract_start_date"
    t.integer "same_supplier_used"
    t.string "document_types", default: [], array: true
    t.text "document_type_other"
    t.integer "origin"
    t.text "origin_other"
    t.index ["category_id"], name: "index_framework_requests_on_category_id"
    t.index ["support_case_id"], name: "index_framework_requests_on_support_case_id"
    t.index ["user_id"], name: "index_framework_requests_on_user_id"
  end

  create_table "frameworks_activity_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "frameworks_activity_log_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.uuid "activity_id"
    t.string "activity_type"
    t.uuid "subject_id"
    t.string "subject_type"
    t.string "guid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_description"
  end

  create_table "frameworks_evaluations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", default: -> { "('FE'::text || nextval('evaluation_refs'::regclass))" }
    t.uuid "framework_id"
    t.uuid "assignee_id"
    t.uuid "contact_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "action_required", default: false
    t.date "next_key_date"
    t.string "next_key_date_description"
    t.integer "creation_source", default: 0
  end

  create_table "frameworks_framework_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_category_id", null: false
    t.uuid "framework_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "frameworks_frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "source", default: 0
    t.integer "status", default: 0
    t.string "name"
    t.string "short_name"
    t.string "url"
    t.string "reference", default: -> { "('F'::text || nextval('framework_refs'::regclass))" }
    t.string "description"
    t.uuid "provider_id", null: false
    t.uuid "provider_contact_id"
    t.date "provider_start_date"
    t.date "provider_end_date"
    t.date "dfe_start_date"
    t.date "dfe_review_date"
    t.string "sct_framework_owner"
    t.string "sct_framework_provider_lead"
    t.uuid "proc_ops_lead_id"
    t.uuid "e_and_o_lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dps", default: true
    t.integer "lot", default: 0
    t.string "provider_reference"
    t.datetime "faf_added_date"
    t.datetime "faf_end_date"
    t.string "faf_slug_ref"
    t.string "faf_category"
    t.date "faf_archived_at"
    t.boolean "is_archived", default: false
  end

  create_table "frameworks_provider_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.uuid "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "frameworks_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.boolean "started", default: false
    t.uuid "category_id"
    t.integer "state", default: 0
    t.string "name"
    t.datetime "finished_at", precision: nil
    t.index ["category_id"], name: "index_journeys_on_category_id"
    t.index ["started"], name: "index_journeys_on_started"
    t.index ["user_id"], name: "index_journeys_on_user_id"
  end

  create_table "local_authorities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "la_code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.index ["la_code"], name: "index_local_authorities_on_la_code", unique: true
    t.index ["name"], name: "index_local_authorities_on_name", unique: true
  end

  create_table "long_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.text "response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_long_text_answers_on_step_id"
  end

  create_table "number_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.integer "response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_number_answers_on_step_id"
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "slug"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "contentful_id"
    t.text "sidebar"
    t.string "breadcrumbs", default: [], array: true
    t.index ["contentful_id"], name: "index_pages_on_contentful_id", unique: true
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "radio_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "further_information"
    t.index ["step_id"], name: "index_radio_answers_on_step_id"
  end

  create_table "request_for_help_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "slug"
    t.uuid "parent_id"
    t.uuid "support_category_id"
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "flow"
    t.index ["parent_id"], name: "index_request_for_help_categories_on_parent_id"
    t.index ["slug"], name: "index_request_for_help_categories_on_slug"
    t.index ["support_category_id"], name: "index_request_for_help_categories_on_support_category_id"
  end

  create_table "sections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "journey_id"
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contentful_id"
    t.integer "order"
    t.index ["journey_id"], name: "index_sections_on_journey_id"
    t.index ["order"], name: "index_sections_on_order"
  end

  create_table "short_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_short_text_answers_on_step_id"
  end

  create_table "single_date_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.date "response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_id"], name: "index_single_date_answers_on_step_id"
  end

  create_table "steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "help_text"
    t.string "contentful_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.string "contentful_model"
    t.string "primary_call_to_action_text"
    t.string "contentful_id", null: false
    t.jsonb "raw", null: false
    t.jsonb "options"
    t.boolean "hidden", default: false
    t.jsonb "additional_step_rules"
    t.string "skip_call_to_action_text"
    t.uuid "task_id"
    t.integer "order"
    t.jsonb "criteria"
    t.index ["order"], name: "index_steps_on_order"
    t.index ["task_id"], name: "index_steps_on_task_id"
  end

  create_table "support_activity_log_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "support_case_id"
    t.string "action"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dsi_uid", default: "", null: false
    t.string "email", default: "", null: false
    t.boolean "internal", default: false, null: false
    t.uuid "support_tower_id"
    t.string "roles", default: [], array: true
    t.index ["dsi_uid"], name: "index_support_agents_on_dsi_uid"
    t.index ["email"], name: "index_support_agents_on_email", unique: true
    t.index ["support_tower_id"], name: "index_support_agents_on_support_tower_id"
  end

  create_table "support_case_additional_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: [], array: true
    t.string "phone_number"
    t.string "extension_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "organisation_id"
    t.index ["support_case_id"], name: "index_support_case_additional_contacts_on_support_case_id"
  end

  create_table "support_case_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.uuid "support_email_attachment_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.string "custom_name"
    t.index ["support_case_id"], name: "index_support_case_attachments_on_support_case_id"
    t.index ["support_email_attachment_id"], name: "index_support_case_attachments_on_support_email_attachment_id"
  end

  create_table "support_case_organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id", null: false
    t.uuid "support_organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_case_id"], name: "index_support_case_organisations_on_support_case_id"
    t.index ["support_organisation_id"], name: "index_support_case_organisations_on_support_organisation_id"
  end

  create_table "support_case_upload_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.string "file_type"
    t.string "file_name"
    t.bigint "file_size"
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_case_id"], name: "index_support_case_upload_documents_on_support_case_id"
  end

  create_table "support_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ref"
    t.uuid "category_id"
    t.string "request_text"
    t.integer "support_level"
    t.integer "status"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "agent_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.integer "source"
    t.uuid "organisation_id"
    t.uuid "existing_contract_id"
    t.uuid "new_contract_id"
    t.uuid "procurement_id"
    t.integer "savings_status"
    t.integer "savings_estimate_method"
    t.integer "savings_actual_method"
    t.decimal "savings_estimate", precision: 10, scale: 2
    t.decimal "savings_actual", precision: 10, scale: 2
    t.boolean "action_required", default: false
    t.string "organisation_type"
    t.decimal "value", precision: 10, scale: 2
    t.integer "closure_reason"
    t.string "extension_number"
    t.string "other_category"
    t.string "other_query"
    t.decimal "procurement_amount", precision: 9, scale: 2
    t.string "confidence_level"
    t.string "special_requirements"
    t.uuid "query_id"
    t.boolean "exit_survey_sent", default: false
    t.uuid "detected_category_id"
    t.integer "creation_source"
    t.text "user_selected_category"
    t.uuid "created_by_id"
    t.uuid "procurement_stage_id"
    t.string "initial_request_text"
    t.boolean "with_school", default: false, null: false
    t.date "next_key_date"
    t.string "next_key_date_description"
    t.integer "discovery_method"
    t.string "discovery_method_other_text"
    t.string "project"
    t.string "other_school_urns", default: [], array: true
    t.boolean "is_evaluator", default: false
    t.date "evaluation_due_date"
    t.boolean "has_uploaded_documents", default: false
    t.boolean "sent_email_to_evaluators", default: false
    t.boolean "has_uploaded_contract_handovers", default: false
    t.boolean "has_shared_handover_pack", default: false
    t.index ["category_id"], name: "index_support_cases_on_category_id"
    t.index ["existing_contract_id"], name: "index_support_cases_on_existing_contract_id"
    t.index ["new_contract_id"], name: "index_support_cases_on_new_contract_id"
    t.index ["procurement_id"], name: "index_support_cases_on_procurement_id"
    t.index ["procurement_stage_id"], name: "index_support_cases_on_procurement_stage_id"
    t.index ["query_id"], name: "index_support_cases_on_query_id"
    t.index ["ref"], name: "index_support_cases_on_ref", unique: true
    t.index ["state"], name: "index_support_cases_on_state"
    t.index ["status"], name: "index_support_cases_on_status"
    t.index ["support_level"], name: "index_support_cases_on_support_level"
  end

  create_table "support_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "slug"
    t.string "description"
    t.uuid "parent_id"
    t.string "tower"
    t.uuid "support_tower_id"
    t.boolean "archived", default: false, null: false
    t.index ["slug"], name: "index_support_categories_on_slug", unique: true
    t.index ["support_tower_id"], name: "index_support_categories_on_support_tower_id"
    t.index ["title", "parent_id"], name: "index_support_categories_on_title_and_parent_id", unique: true
  end

  create_table "support_contract_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "dsi_uid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_downloaded_documents", default: false
    t.index ["dsi_uid"], name: "index_support_contract_recipients_on_dsi_uid"
    t.index ["email", "support_case_id"], name: "index_support_contract_recipients_on_email_and_support_case_id", unique: true
    t.index ["support_case_id"], name: "index_support_contract_recipients_on_support_case_id"
  end

  create_table "support_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "supplier"
    t.date "started_at"
    t.date "ended_at"
    t.interval "duration"
    t.decimal "spend", precision: 10, scale: 2
    t.boolean "is_supplier_sme", default: false
  end

  create_table "support_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.string "document_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "case_id"
    t.index ["case_id"], name: "index_support_documents_on_case_id"
  end

  create_table "support_download_contract_handovers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.uuid "support_upload_contract_handover_id"
    t.string "email", null: false
    t.boolean "has_downloaded_documents", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "support_case_id", "support_upload_contract_handover_id"], name: "idx_on_email_support_case_id_support_upload_contract_e4763cd05c", unique: true
    t.index ["support_case_id"], name: "index_support_download_contract_handovers_on_support_case_id"
    t.index ["support_upload_contract_handover_id"], name: "idx_on_support_upload_contract_handover_id_044312d42c"
  end

  create_table "support_email_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.string "file_name"
    t.bigint "file_size"
    t.uuid "email_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_inline", default: false
    t.string "content_id"
    t.string "outlook_id"
    t.string "custom_name"
    t.string "description"
    t.boolean "hidden", default: false
    t.index ["email_id"], name: "index_support_email_attachments_on_email_id"
  end

  create_table "support_email_template_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.string "file_name"
    t.bigint "file_size"
    t.uuid "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_support_email_template_attachments_on_template_id"
  end

  create_table "support_email_template_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.uuid "parent_id"
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_support_email_template_groups_on_parent_id"
  end

  create_table "support_email_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.uuid "template_group_id", null: false
    t.integer "stage"
    t.string "subject"
    t.text "body", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_support_email_templates_on_created_by_id"
    t.index ["template_group_id"], name: "index_support_email_templates_on_template_group_id"
    t.index ["updated_by_id"], name: "index_support_email_templates_on_updated_by_id"
  end

  create_table "support_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subject"
    t.text "body"
    t.jsonb "sender"
    t.jsonb "recipients"
    t.string "outlook_conversation_id"
    t.uuid "case_id"
    t.datetime "sent_at", precision: nil
    t.datetime "outlook_received_at", precision: nil
    t.datetime "outlook_read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "outlook_id"
    t.boolean "outlook_is_read", default: false
    t.boolean "outlook_is_draft", default: false
    t.boolean "outlook_has_attachments", default: false
    t.integer "folder"
    t.boolean "is_read", default: false
    t.string "case_reference_from_headers"
    t.string "outlook_internet_message_id"
    t.string "in_reply_to_id"
    t.text "unique_body"
    t.jsonb "to_recipients"
    t.jsonb "cc_recipients"
    t.jsonb "bcc_recipients"
    t.uuid "template_id"
    t.string "ticket_type"
    t.uuid "ticket_id"
    t.boolean "is_draft", default: false
    t.index ["in_reply_to_id"], name: "index_support_emails_on_in_reply_to_id"
    t.index ["outlook_conversation_id", "sent_at"], name: "index_support_emails_on_outlook_conversation_id_and_sent_at", order: { sent_at: :desc }
    t.index ["outlook_conversation_id", "ticket_id", "ticket_type"], name: "idx_on_outlook_conversation_id_ticket_id_ticket_typ_9df6d5a50e"
    t.index ["template_id"], name: "index_support_emails_on_template_id"
    t.index ["ticket_id", "ticket_type"], name: "index_support_emails_on_ticket_id_and_ticket_type"
  end

  create_table "support_establishment_group_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_support_establishment_group_types_on_code", unique: true
    t.index ["name"], name: "index_support_establishment_group_types_on_name", unique: true
  end

  create_table "support_establishment_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "ukprn"
    t.string "uid"
    t.integer "status", null: false
    t.jsonb "address"
    t.uuid "establishment_group_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.date "opened_date"
    t.date "closed_date"
    t.index ["establishment_group_type_id"], name: "index_establishment_groups_on_establishment_group_type_id"
    t.index ["name"], name: "index_support_establishment_groups_on_name"
    t.index ["uid"], name: "index_support_establishment_groups_on_uid", unique: true
    t.index ["ukprn"], name: "index_support_establishment_groups_on_ukprn"
  end

  create_table "support_establishment_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "group_type_id", null: false
    t.string "name", null: false
    t.integer "code", null: false
    t.integer "organisations_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_support_establishment_types_on_code", unique: true
    t.index ["name"], name: "index_support_establishment_types_on_name", unique: true
  end

  create_table "support_evaluators", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "dsi_uid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_uploaded_documents", default: false
    t.boolean "evaluation_approved", default: false
    t.boolean "has_downloaded_documents", default: false
    t.index ["dsi_uid"], name: "index_support_evaluators_on_dsi_uid"
    t.index ["email", "support_case_id"], name: "index_support_evaluators_on_email_and_support_case_id", unique: true
    t.index ["support_case_id"], name: "index_support_evaluators_on_support_case_id"
  end

  create_table "support_evaluators_download_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.uuid "support_case_upload_document_id"
    t.string "email", null: false
    t.boolean "has_downloaded_documents", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "support_case_id", "support_case_upload_document_id"], name: "idx_on_email_support_case_id_support_case_upload_do_e4a88327e6", unique: true
    t.index ["support_case_id"], name: "index_support_evaluators_download_documents_on_support_case_id"
    t.index ["support_case_upload_document_id"], name: "idx_on_support_case_upload_document_id_fbb53116e2"
  end

  create_table "support_evaluators_upload_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.string "email", null: false
    t.string "file_type"
    t.string "file_name"
    t.bigint "file_size"
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "evaluation_submitted", default: true
    t.index ["support_case_id"], name: "index_support_evaluators_upload_documents_on_support_case_id"
  end

  create_table "support_frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "supplier"
    t.string "category"
    t.date "expires_at"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "ref"
    t.index ["name", "supplier"], name: "index_support_frameworks_on_name_and_supplier", unique: true
    t.index ["ref"], name: "index_support_frameworks_on_ref", unique: true
  end

  create_table "support_group_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "code", null: false
    t.integer "establishment_types_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_support_group_types_on_code", unique: true
    t.index ["name"], name: "index_support_group_types_on_name", unique: true
  end

  create_table "support_hub_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "case_id"
    t.string "hub_case_ref"
    t.date "estimated_procurement_completion_date"
    t.decimal "estimated_savings", precision: 8, scale: 2
    t.string "school_urn"
    t.string "buying_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_support_hub_transitions_on_case_id"
    t.index ["hub_case_ref"], name: "index_support_hub_transitions_on_hub_case_ref"
  end

  create_table "support_interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id"
    t.uuid "case_id"
    t.integer "event_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "additional_data", default: {}, null: false
    t.boolean "show_case_history", default: true
    t.index ["agent_id"], name: "index_support_interactions_on_agent_id"
    t.index ["case_id"], name: "index_support_interactions_on_case_id"
    t.index ["event_type"], name: "index_support_interactions_on_event_type"
  end

  create_table "support_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by_id"
    t.uuid "assigned_to_id", null: false
    t.boolean "assigned_by_system", default: false
    t.boolean "read", default: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "support_case_id"
    t.integer "topic"
    t.string "subject_type"
    t.uuid "subject_id"
    t.index ["assigned_by_id"], name: "index_support_notifications_on_assigned_by_id"
    t.index ["assigned_to_id"], name: "index_support_notifications_on_assigned_to_id"
    t.index ["subject_type", "subject_id"], name: "index_support_notifications_on_subject"
  end

  create_table "support_organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "establishment_type_id"
    t.string "urn", null: false
    t.string "name", null: false
    t.jsonb "address", null: false
    t.jsonb "contact", null: false
    t.integer "phase"
    t.integer "gender"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ukprn"
    t.string "telephone_number"
    t.jsonb "local_authority_legacy"
    t.datetime "opened_date", precision: nil
    t.string "number"
    t.string "rsc_region"
    t.string "trust_name"
    t.string "trust_code"
    t.string "gor_name"
    t.string "federation_name"
    t.string "federation_code"
    t.uuid "local_authority_id"
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.date "closed_date"
    t.string "reason_establishment_opened"
    t.string "reason_establishment_closed"
    t.index ["establishment_type_id"], name: "index_support_organisations_on_establishment_type_id"
    t.index ["local_authority_id"], name: "index_support_organisations_on_local_authority_id"
    t.index ["urn"], name: "index_support_organisations_on_urn", unique: true
  end

  create_table "support_procurement_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "key", null: false
    t.integer "stage", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lifecycle_order"
    t.index ["key"], name: "index_support_procurement_stages_on_key", unique: true
  end

  create_table "support_procurements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "required_agreement_type"
    t.integer "route_to_market"
    t.integer "reason_for_route_to_market"
    t.date "started_at"
    t.date "ended_at"
    t.integer "stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "framework_id"
    t.uuid "frameworks_framework_id"
    t.string "e_portal_reference"
    t.index ["framework_id"], name: "index_support_procurements_on_framework_id"
    t.index ["stage"], name: "index_support_procurements_on_stage"
  end

  create_table "support_queries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_id"
    t.uuid "journey_id"
    t.uuid "category_id"
    t.string "message_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.boolean "submitted", default: false, null: false
    t.string "school_urn"
    t.decimal "procurement_amount", precision: 9, scale: 2
    t.integer "confidence_level"
    t.string "special_requirements"
    t.index ["category_id"], name: "index_support_requests_on_category_id"
    t.index ["journey_id"], name: "index_support_requests_on_journey_id"
    t.index ["user_id"], name: "index_support_requests_on_user_id"
  end

  create_table "support_towers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
  end

  create_table "support_upload_contract_handovers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.string "file_type"
    t.string "file_name"
    t.bigint "file_size"
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_case_id"], name: "index_support_upload_contract_handovers_on_support_case_id"
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "section_id"
    t.string "title", null: false
    t.string "contentful_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.jsonb "step_tally", default: "{}"
    t.text "statement_ids", default: [], null: false, array: true
    t.text "skipped_ids", default: [], null: false, array: true
    t.index ["order"], name: "index_tasks_on_order"
    t.index ["section_id"], name: "index_tasks_on_section_id"
    t.index ["skipped_ids"], name: "index_tasks_on_skipped_ids", using: :gin
    t.index ["statement_ids"], name: "index_tasks_on_statement_ids"
  end

  create_table "user_feedback", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "service", null: false
    t.integer "satisfaction", null: false
    t.string "feedback_text"
    t.boolean "logged_in", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "email"
    t.uuid "logged_in_as_id"
    t.index ["logged_in_as_id"], name: "index_user_feedback_on_logged_in_as_id"
  end

  create_table "user_journey_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "product_section"
    t.string "step_description"
    t.uuid "user_journey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_journey_id"], name: "index_user_journey_steps_on_user_journey_id"
  end

  create_table "user_journeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status"
    t.uuid "case_id"
    t.string "referral_campaign"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "framework_request_id"
    t.string "session_id"
    t.index ["case_id"], name: "index_user_journeys_on_case_id"
    t.index ["framework_request_id"], name: "index_user_journeys_on_framework_request_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "dfe_sign_in_uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.jsonb "orgs"
    t.jsonb "roles"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["last_name"], name: "index_users_on_last_name"
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "all_cases_survey_responses", "support_cases", column: "case_id"
  add_foreign_key "case_requests", "support_agents", column: "created_by_id"
  add_foreign_key "case_requests", "support_cases"
  add_foreign_key "case_requests", "support_categories", column: "category_id"
  add_foreign_key "case_requests", "support_queries", column: "query_id"
  add_foreign_key "documents", "framework_requests"
  add_foreign_key "documents", "support_cases"
  add_foreign_key "energy_electricity_meters", "energy_onboarding_case_organisations"
  add_foreign_key "energy_gas_meters", "energy_onboarding_case_organisations"
  add_foreign_key "energy_onboarding_case_organisations", "energy_onboarding_cases"
  add_foreign_key "energy_onboarding_cases", "support_cases"
  add_foreign_key "engagement_case_uploads", "case_requests"
  add_foreign_key "exit_survey_responses", "support_cases", column: "case_id"
  add_foreign_key "framework_requests", "request_for_help_categories", column: "category_id"
  add_foreign_key "framework_requests", "support_cases"
  add_foreign_key "framework_requests", "users"
  add_foreign_key "long_text_answers", "steps", on_delete: :cascade
  add_foreign_key "radio_answers", "steps", on_delete: :cascade
  add_foreign_key "request_for_help_categories", "request_for_help_categories", column: "parent_id"
  add_foreign_key "request_for_help_categories", "support_categories"
  add_foreign_key "short_text_answers", "steps", on_delete: :cascade
  add_foreign_key "support_agents", "support_towers"
  add_foreign_key "support_case_additional_contacts", "support_cases"
  add_foreign_key "support_case_attachments", "support_cases"
  add_foreign_key "support_case_attachments", "support_email_attachments"
  add_foreign_key "support_case_organisations", "support_cases"
  add_foreign_key "support_case_organisations", "support_organisations"
  add_foreign_key "support_cases", "support_contracts", column: "existing_contract_id"
  add_foreign_key "support_cases", "support_contracts", column: "new_contract_id"
  add_foreign_key "support_cases", "support_procurement_stages", column: "procurement_stage_id"
  add_foreign_key "support_cases", "support_procurements", column: "procurement_id"
  add_foreign_key "support_cases", "support_queries", column: "query_id"
  add_foreign_key "support_categories", "support_towers"
  add_foreign_key "support_email_template_attachments", "support_email_templates", column: "template_id"
  add_foreign_key "support_email_template_groups", "support_email_template_groups", column: "parent_id"
  add_foreign_key "support_email_templates", "support_agents", column: "created_by_id"
  add_foreign_key "support_email_templates", "support_agents", column: "updated_by_id"
  add_foreign_key "support_email_templates", "support_email_template_groups", column: "template_group_id"
  add_foreign_key "support_emails", "support_email_templates", column: "template_id"
  add_foreign_key "support_notifications", "support_agents", column: "assigned_by_id"
  add_foreign_key "support_notifications", "support_agents", column: "assigned_to_id"
  add_foreign_key "support_notifications", "support_cases"
  add_foreign_key "support_organisations", "local_authorities"
  add_foreign_key "support_procurements", "support_frameworks", column: "framework_id"
  add_foreign_key "user_feedback", "users", column: "logged_in_as_id"
  add_foreign_key "user_journey_steps", "user_journeys"
  add_foreign_key "user_journeys", "framework_requests"
  add_foreign_key "user_journeys", "support_cases", column: "case_id"

  create_view "support_message_threads", sql_definition: <<-SQL
      SELECT DISTINCT ON (se.outlook_conversation_id, se.ticket_id) se.outlook_conversation_id AS conversation_id,
      se.case_id,
      se.ticket_id,
      se.ticket_type,
      ( SELECT jsonb_agg(DISTINCT elems.value) AS jsonb_agg
             FROM support_emails se2,
              LATERAL jsonb_array_elements(se2.recipients) elems(value)
            WHERE ((se2.outlook_conversation_id)::text = (se.outlook_conversation_id)::text)) AS recipients,
      se.subject,
      ( SELECT se2.sent_at
             FROM support_emails se2
            WHERE ((se2.outlook_conversation_id)::text = (se.outlook_conversation_id)::text)
            ORDER BY se2.sent_at DESC
           LIMIT 1) AS last_updated
     FROM support_emails se;
  SQL
  create_view "frameworks_framework_data", sql_definition: <<-SQL
      SELECT ff.id AS framework_id,
      ff.source,
      ff.status,
      ff.name,
      ff.short_name,
      ff.url,
      ff.reference,
      fp.name AS provider_name,
      fp.short_name AS provider_short_name,
      fpc.name AS provider_contact_name,
      fpc.email AS provider_contact_email,
      ff.provider_start_date,
      ff.provider_end_date,
      ff.dfe_start_date,
      ff.dfe_review_date,
      ff.sct_framework_owner,
      ff.sct_framework_provider_lead,
      (((sap.first_name)::text || ' '::text) || (sap.last_name)::text) AS procops_lead_name,
      sap.email AS procops_lead_email,
      (((saeo.first_name)::text || ' '::text) || (saeo.last_name)::text) AS e_and_o_lead_name,
      saeo.email AS e_and_o_lead_email,
      (ff.created_at)::date AS created_at,
      (ff.updated_at)::date AS updated_at,
      ff.dps,
      ff.lot,
      ff.provider_reference,
      (ff.faf_added_date)::date AS faf_added_date,
      (ff.faf_end_date)::date AS faf_end_date,
      cats.categories,
          CASE
              WHEN (evals.has_evaluation IS NOT NULL) THEN 'Yes'::text
              ELSE 'No'::text
          END AS has_evaluation
     FROM ((((((frameworks_frameworks ff
       LEFT JOIN frameworks_providers fp ON ((ff.provider_id = fp.id)))
       LEFT JOIN frameworks_provider_contacts fpc ON ((ff.provider_contact_id = fpc.id)))
       LEFT JOIN support_agents sap ON ((ff.proc_ops_lead_id = sap.id)))
       LEFT JOIN support_agents saeo ON ((ff.e_and_o_lead_id = saeo.id)))
       LEFT JOIN ( SELECT ffc.framework_id,
              jsonb_agg(sc.title) AS categories
             FROM (frameworks_framework_categories ffc
               LEFT JOIN support_categories sc ON ((sc.id = ffc.support_category_id)))
            GROUP BY ffc.framework_id) cats ON ((cats.framework_id = ff.id)))
       LEFT JOIN ( SELECT ffe.framework_id,
              count(ffe.id) AS has_evaluation
             FROM frameworks_evaluations ffe
            GROUP BY ffe.framework_id) evals ON ((evals.framework_id = ff.id)));
  SQL
  create_view "support_tower_cases", sql_definition: <<-SQL
      SELECT sc.id,
      sc.state,
      sc.value,
      sc.procurement_id,
      sc.organisation_id,
      (sc.procurement_stage_id)::text AS procurement_stage_id,
      COALESCE(sc.support_level, 99) AS support_level,
      COALESCE(tow.title, 'No Tower'::character varying) AS tower_name,
      lower(replace((COALESCE(tow.title, 'No Tower'::character varying))::text, ' '::text, '-'::text)) AS tower_slug,
      tow.id AS tower_id,
      sc.created_at,
      sc.updated_at
     FROM ((support_cases sc
       LEFT JOIN support_categories cat ON ((sc.category_id = cat.id)))
       LEFT JOIN support_towers tow ON ((cat.support_tower_id = tow.id)))
    WHERE (sc.state = ANY (ARRAY[0, 1, 3]));
  SQL
  create_view "support_establishment_searches", sql_definition: <<-SQL
      SELECT organisations.id,
      organisations.name,
      (organisations.address ->> 'postcode'::text) AS postcode,
      organisations.urn,
      organisations.ukprn,
      etypes.name AS establishment_type,
      'Support::Organisation'::text AS source,
      NULL::text AS code,
      organisations.status AS organisation_status,
      organisations.opened_date,
      organisations.closed_date
     FROM (support_organisations organisations
       JOIN support_establishment_types etypes ON ((etypes.id = organisations.establishment_type_id)))
    WHERE ((organisations.status <> 2) AND (organisations.archived IS NOT TRUE))
  UNION ALL
   SELECT egroups.id,
      egroups.name,
      (egroups.address ->> 'postcode'::text) AS postcode,
      NULL::character varying AS urn,
      egroups.ukprn,
      egtypes.name AS establishment_type,
      'Support::EstablishmentGroup'::text AS source,
      NULL::text AS code,
      NULL::integer AS organisation_status,
      egroups.opened_date,
      egroups.closed_date
     FROM (support_establishment_groups egroups
       JOIN support_establishment_group_types egtypes ON ((egtypes.id = egroups.establishment_group_type_id)))
    WHERE ((egroups.status <> 2) AND (egroups.archived IS NOT TRUE))
  UNION ALL
   SELECT local_authorities.id,
      local_authorities.name,
      NULL::text AS postcode,
      NULL::character varying AS urn,
      NULL::character varying AS ukprn,
      'Local authority'::character varying AS establishment_type,
      'LocalAuthority'::text AS source,
      local_authorities.la_code AS code,
      NULL::integer AS organisation_status,
      NULL::timestamp without time zone AS opened_date,
      NULL::date AS closed_date
     FROM local_authorities
    WHERE (local_authorities.archived IS NOT TRUE)
    ORDER BY 9;
  SQL
  create_view "support_case_searches", sql_definition: <<-SQL
      SELECT sc.id AS case_id,
      sc.ref AS case_ref,
      sc.created_at,
      sc.updated_at,
      sc.state AS case_state,
      sc.email AS case_email,
      ses.name AS organisation_name,
      ses.urn AS organisation_urn,
      ses.ukprn AS organisation_ukprn,
      (((sa.first_name)::text || ' '::text) || (sa.last_name)::text) AS agent_name,
      sa.first_name AS agent_first_name,
      sa.last_name AS agent_last_name,
      cat.title AS category_title
     FROM (((support_cases sc
       LEFT JOIN support_agents sa ON ((sa.id = sc.agent_id)))
       LEFT JOIN support_establishment_searches ses ON (((sc.organisation_id = ses.id) AND ((sc.organisation_type)::text = ses.source))))
       LEFT JOIN support_categories cat ON ((sc.category_id = cat.id)));
  SQL
  create_view "ticket_searches", sql_definition: <<-SQL
      SELECT scs.case_id AS id,
      scs.case_ref AS reference,
      scs.organisation_name,
      scs.organisation_urn,
      scs.organisation_ukprn,
      NULL::character varying AS framework_name,
      NULL::character varying AS framework_provider,
      scs.agent_name,
      scs.agent_first_name,
      scs.agent_last_name,
      scs.created_at,
      scs.updated_at,
      'Support::Case'::text AS source
     FROM support_case_searches scs
  UNION ALL
   SELECT fe.id,
      fe.reference,
      NULL::character varying AS organisation_name,
      NULL::character varying AS organisation_urn,
      NULL::character varying AS organisation_ukprn,
      ff.name AS framework_name,
      fp.short_name AS framework_provider,
      (((sa.first_name)::text || ' '::text) || (sa.last_name)::text) AS agent_name,
      sa.first_name AS agent_first_name,
      sa.last_name AS agent_last_name,
      fe.created_at,
      fe.updated_at,
      'Frameworks::Evaluation'::text AS source
     FROM (((frameworks_evaluations fe
       LEFT JOIN frameworks_frameworks ff ON ((ff.id = fe.framework_id)))
       LEFT JOIN frameworks_providers fp ON ((fp.id = ff.provider_id)))
       LEFT JOIN support_agents sa ON ((sa.id = fe.assignee_id)));
  SQL
  create_view "support_case_data", sql_definition: <<-SQL
      SELECT sc.id AS case_id,
      sc.ref AS case_ref,
      sc.created_at,
      (sc.created_at)::date AS created_date,
      to_char(((sc.created_at)::date)::timestamp with time zone, 'yyyy'::text) AS created_year,
      to_char(((sc.created_at)::date)::timestamp with time zone, 'mm'::text) AS created_month,
          CASE
              WHEN (date_part('month'::text, sc.created_at) >= (4)::double precision) THEN concat('FY', to_char(((sc.created_at)::date)::timestamp with time zone, 'yy'::text), '/', to_char((((sc.created_at + 'P1Y'::interval))::date)::timestamp with time zone, 'yy'::text))
              WHEN (date_part('month'::text, sc.created_at) < (4)::double precision) THEN concat('FY', to_char((((sc.created_at - 'P1Y'::interval))::date)::timestamp with time zone, 'yy'::text), '/', to_char(((sc.created_at)::date)::timestamp with time zone, 'yy'::text))
              ELSE NULL::text
          END AS created_financial_year,
      GREATEST(sc.updated_at, si.created_at) AS last_modified_at,
      (GREATEST(sc.updated_at, si.created_at))::date AS last_modified_date,
      to_char(((GREATEST(sc.updated_at, si.created_at))::date)::timestamp with time zone, 'yyyy'::text) AS last_modified_year,
      to_char(((GREATEST(sc.updated_at, si.created_at))::date)::timestamp with time zone, 'mm'::text) AS last_modified_month,
      (rl.first_resolved_at)::date AS first_resolved_date,
      (rl.last_resolved_at)::date AS last_resolved_date,
      sc.source AS case_source,
      sc.creation_source AS case_creation_source,
      sc.state AS case_state,
      sc.closure_reason AS case_closure_reason,
      cat.title AS sub_category_title,
      sc.other_category AS category_other,
      stc.tower_name,
      concat(sa.first_name, ' ', sa.last_name) AS agent_name,
      sc.savings_actual,
      sc.savings_actual_method,
      sc.savings_estimate,
      sc.savings_estimate_method,
      sc.savings_status,
      sc.support_level AS case_support_level,
      sc.value AS case_value,
      sc.with_school AS with_school_flag,
      sc.next_key_date,
      sc.next_key_date_description,
      sc.email AS organisation_contact_email,
      se.name AS organisation_name,
      se.urn AS organisation_urn,
      se.ukprn AS organisation_ukprn,
      se.rsc_region AS organisation_rsc_region,
      se.trust_name AS parent_group_name,
      se.trust_code AS parent_group_ukprn,
      se.local_authority_name AS organisation_local_authority_name,
      se.local_authority_code AS organisation_local_authority_code,
      se.gor_name,
      se.uid AS organisation_uid,
      se.phase AS organisation_phase,
      se.organisation_status,
      se.egroup_status AS establishment_group_status,
      se.establishment_type,
      array_length(fr.school_urns, 1) AS framework_request_num_schools,
      replace(btrim((fr.school_urns)::text, '{}"'::text), ','::text, ', '::text) AS framework_request_school_urns,
      array_length(cr.school_urns, 1) AS case_request_num_schools,
      replace(btrim((cr.school_urns)::text, '{}"'::text), ','::text, ', '::text) AS case_request_school_urns,
      jsonb_array_length(cps.participating_schools) AS case_num_participating_schools,
      replace(btrim((cps.participating_schools)::text, '[]'::text), '"'::text, ''::text) AS case_participating_school_urns,
      sf.name AS legacy_framework,
      ff.name AS framework_name,
      sp.reason_for_route_to_market,
      sp.required_agreement_type,
      sp.route_to_market,
      sp.stage AS procurement_stage_old,
      sps.stage AS procurement_stage,
      sps.key AS procurement_stage_key,
      sp.started_at AS procurement_started_at,
      sp.ended_at AS procurement_ended_at,
      sp.e_portal_reference,
      ec.started_at AS previous_contract_started_at,
      ec.ended_at AS previous_contract_ended_at,
      ec.duration AS previous_contract_duration,
      ec.spend AS previous_contract_spend,
      ec.supplier AS previous_contract_supplier,
      nc.started_at AS new_contract_started_at,
      nc.ended_at AS new_contract_ended_at,
      nc.duration AS new_contract_duration,
      nc.spend AS new_contract_spend,
      nc.supplier AS new_contract_supplier,
      nc.is_supplier_sme AS supplier_is_a_sme,
      ps.created_at AS participation_survey_date,
      es.created_at AS exit_survey_date,
      (sir.additional_data ->> 'referrer'::text) AS referrer
     FROM ((((((((((((((((((support_cases sc
       LEFT JOIN ( SELECT sa_1.id,
              sa_1.first_name,
              sa_1.last_name
             FROM support_agents sa_1) sa ON ((sc.agent_id = sa.id)))
       LEFT JOIN ( SELECT stc_1.id,
              stc_1.procurement_id,
              stc_1.tower_name
             FROM support_tower_cases stc_1) stc ON ((sc.procurement_id = stc.procurement_id)))
       LEFT JOIN ( SELECT log.support_case_id AS case_id,
              min(log.created_at) AS first_resolved_at,
              max(log.created_at) AS last_resolved_at
             FROM support_activity_log_items log
            WHERE ((log.action)::text = 'resolve_case'::text)
            GROUP BY log.support_case_id) rl ON ((((sc.id)::character varying)::text = (rl.case_id)::text)))
       LEFT JOIN ( SELECT fr_1.id,
              fr_1.support_case_id,
              fr_1.school_urns
             FROM framework_requests fr_1) fr ON ((sc.id = fr.support_case_id)))
       LEFT JOIN ( SELECT cr_1.id,
              cr_1.support_case_id,
              cr_1.school_urns
             FROM case_requests cr_1) cr ON ((sc.id = cr.support_case_id)))
       LEFT JOIN ( SELECT sco.support_case_id,
              jsonb_agg(so.urn) AS participating_schools
             FROM (support_case_organisations sco
               LEFT JOIN support_organisations so ON ((so.id = sco.support_organisation_id)))
            GROUP BY sco.support_case_id) cps ON ((cps.support_case_id = sc.id)))
       LEFT JOIN support_interactions si ON ((si.id = ( SELECT i.id
             FROM support_interactions i
            WHERE (i.case_id = sc.id)
            ORDER BY i.created_at
           LIMIT 1))))
       LEFT JOIN ( SELECT organisations.id,
              organisations.name,
              organisations.rsc_region,
              local_authorities.name AS local_authority_name,
              local_authorities.la_code AS local_authority_code,
              organisations.gor_name,
              organisations.urn,
              organisations.ukprn,
              parent.name AS trust_name,
              parent.ukprn AS trust_code,
              organisations.status AS organisation_status,
              NULL::integer AS egroup_status,
              NULL::character varying AS uid,
              organisations.phase,
              etypes.name AS establishment_type,
              'Support::Organisation'::text AS source
             FROM (((support_organisations organisations
               JOIN support_establishment_types etypes ON ((etypes.id = organisations.establishment_type_id)))
               JOIN local_authorities ON ((local_authorities.id = organisations.local_authority_id)))
               LEFT JOIN support_establishment_groups parent ON (((parent.uid)::text = COALESCE(NULLIF((organisations.trust_code)::text, ''::text), (organisations.federation_code)::text))))
          UNION ALL
           SELECT egroups.id,
              egroups.name,
              NULL::character varying AS rsc_region,
              NULL::character varying AS local_authority_name,
              NULL::character varying AS local_authority_code,
              NULL::character varying AS gor_name,
              NULL::character varying AS urn,
              egroups.ukprn,
              egroups.name AS trust_name,
              egroups.ukprn AS trust_code,
              NULL::integer AS organisation_status,
              egroups.status AS egroup_status,
              egroups.uid,
              NULL::integer AS phase,
              egtypes.name AS establishment_type,
              'Support::EstablishmentGroup'::text AS source
             FROM (support_establishment_groups egroups
               JOIN support_establishment_group_types egtypes ON ((egtypes.id = egroups.establishment_group_type_id)))
          UNION ALL
           SELECT la.id,
              la.name,
              NULL::character varying AS rsc_region,
              la.name AS local_authority_name,
              la.la_code AS local_authority_code,
              NULL::character varying AS gor_name,
              NULL::character varying AS urn,
              NULL::character varying AS ukprn,
              NULL::character varying AS trust_name,
              NULL::character varying AS trust_code,
              NULL::integer AS organisation_status,
              NULL::integer AS egroup_status,
              NULL::character varying AS uid,
              NULL::integer AS phase,
              'Local Authority'::character varying AS establishment_type,
              'LocalAuthority'::text AS source
             FROM local_authorities la) se ON (((sc.organisation_id = se.id) AND ((sc.organisation_type)::text = se.source))))
       LEFT JOIN support_categories cat ON ((sc.category_id = cat.id)))
       LEFT JOIN support_procurements sp ON ((sc.procurement_id = sp.id)))
       LEFT JOIN support_procurement_stages sps ON ((sc.procurement_stage_id = sps.id)))
       LEFT JOIN support_frameworks sf ON ((sp.framework_id = sf.id)))
       LEFT JOIN frameworks_frameworks ff ON ((sp.frameworks_framework_id = ff.id)))
       LEFT JOIN support_contracts ec ON ((sc.existing_contract_id = ec.id)))
       LEFT JOIN support_contracts nc ON ((sc.new_contract_id = nc.id)))
       LEFT JOIN support_interactions ps ON ((ps.id = ( SELECT i.id
             FROM support_interactions i
            WHERE ((i.event_type = 3) AND (i.case_id = sc.id) AND ((i.additional_data ->> 'email_template'::text) = 'fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779'::text))
            ORDER BY i.created_at
           LIMIT 1))))
       LEFT JOIN support_interactions es ON ((es.id = ( SELECT i.id
             FROM support_interactions i
            WHERE ((i.case_id = sc.id) AND (i.body = ANY (ARRAY['The exit survey email has been sent'::text, 'The survey for resolved cases email has been sent'::text])))
            ORDER BY i.created_at
           LIMIT 1))))
       LEFT JOIN support_interactions sir ON ((sir.id = ( SELECT i.id
             FROM support_interactions i
            WHERE ((i.event_type = 8) AND (i.case_id = sc.id))
            ORDER BY i.created_at
           LIMIT 1))));
  SQL
end
