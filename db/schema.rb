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

ActiveRecord::Schema[7.0].define(version: 2022_10_27_064825) do
  # These are extensions that must be enabled in order to support this database
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
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.string "value"
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
    t.index ["user_id"], name: "index_framework_requests_on_user_id"
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
    t.index ["dsi_uid"], name: "index_support_agents_on_dsi_uid"
    t.index ["email"], name: "index_support_agents_on_email"
    t.index ["support_tower_id"], name: "index_support_agents_on_support_tower_id"
  end

  create_table "support_case_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_case_id"
    t.uuid "support_email_attachment_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_case_id"], name: "index_support_case_attachments_on_support_case_id"
    t.index ["support_email_attachment_id"], name: "index_support_case_attachments_on_support_email_attachment_id"
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
    t.decimal "savings_estimate", precision: 9, scale: 2
    t.decimal "savings_actual", precision: 9, scale: 2
    t.boolean "action_required", default: false
    t.string "organisation_type"
    t.decimal "value", precision: 9, scale: 2
    t.integer "closure_reason"
    t.string "extension_number"
    t.string "other_category"
    t.string "other_query"
    t.decimal "procurement_amount", precision: 9, scale: 2
    t.string "confidence_level"
    t.string "special_requirements"
    t.uuid "query_id"
    t.boolean "exit_survey_sent", default: false
    t.index ["category_id"], name: "index_support_cases_on_category_id"
    t.index ["existing_contract_id"], name: "index_support_cases_on_existing_contract_id"
    t.index ["new_contract_id"], name: "index_support_cases_on_new_contract_id"
    t.index ["procurement_id"], name: "index_support_cases_on_procurement_id"
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
    t.index ["slug"], name: "index_support_categories_on_slug", unique: true
    t.index ["support_tower_id"], name: "index_support_categories_on_support_tower_id"
    t.index ["title", "parent_id"], name: "index_support_categories_on_title_and_parent_id", unique: true
  end

  create_table "support_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "supplier"
    t.date "started_at"
    t.date "ended_at"
    t.interval "duration"
    t.decimal "spend", precision: 9, scale: 2
  end

  create_table "support_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.string "document_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "case_id"
    t.index ["case_id"], name: "index_support_documents_on_case_id"
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
    t.index ["in_reply_to_id"], name: "index_support_emails_on_in_reply_to_id"
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

  create_table "support_frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "supplier"
    t.string "category"
    t.date "expires_at"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["name", "supplier"], name: "index_support_frameworks_on_name_and_supplier", unique: true
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
    t.index ["agent_id"], name: "index_support_interactions_on_agent_id"
    t.index ["case_id"], name: "index_support_interactions_on_case_id"
    t.index ["event_type"], name: "index_support_interactions_on_event_type"
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
    t.jsonb "local_authority"
    t.datetime "opened_date", precision: nil
    t.string "number"
    t.string "rsc_region"
    t.string "trust_name"
    t.string "trust_code"
    t.string "gor_name"
    t.index ["establishment_type_id"], name: "index_support_organisations_on_establishment_type_id"
    t.index ["urn"], name: "index_support_organisations_on_urn", unique: true
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
    t.uuid "session_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exit_survey_responses", "support_cases", column: "case_id"
  add_foreign_key "framework_requests", "users"
  add_foreign_key "long_text_answers", "steps", on_delete: :cascade
  add_foreign_key "radio_answers", "steps", on_delete: :cascade
  add_foreign_key "short_text_answers", "steps", on_delete: :cascade
  add_foreign_key "support_agents", "support_towers"
  add_foreign_key "support_case_attachments", "support_cases"
  add_foreign_key "support_case_attachments", "support_email_attachments"
  add_foreign_key "support_cases", "support_contracts", column: "existing_contract_id"
  add_foreign_key "support_cases", "support_contracts", column: "new_contract_id"
  add_foreign_key "support_cases", "support_procurements", column: "procurement_id"
  add_foreign_key "support_cases", "support_queries", column: "query_id"
  add_foreign_key "support_categories", "support_towers"
  add_foreign_key "support_procurements", "support_frameworks", column: "framework_id"
  add_foreign_key "user_feedback", "users", column: "logged_in_as_id"
  add_foreign_key "user_journey_steps", "user_journeys"
  add_foreign_key "user_journeys", "framework_requests"
  add_foreign_key "user_journeys", "support_cases", column: "case_id"

  create_view "support_establishment_searches", sql_definition: <<-SQL
      SELECT organisations.id,
      organisations.name,
      (organisations.address ->> 'postcode'::text) AS postcode,
      organisations.urn,
      organisations.ukprn,
      etypes.name AS establishment_type,
      'Support::Organisation'::text AS source
     FROM (support_organisations organisations
       JOIN support_establishment_types etypes ON ((etypes.id = organisations.establishment_type_id)))
    WHERE (organisations.status <> 2)
  UNION ALL
   SELECT egroups.id,
      egroups.name,
      (egroups.address ->> 'postcode'::text) AS postcode,
      NULL::character varying AS urn,
      egroups.ukprn,
      egtypes.name AS establishment_type,
      'Support::EstablishmentGroup'::text AS source
     FROM (support_establishment_groups egroups
       JOIN support_establishment_group_types egtypes ON ((egtypes.id = egroups.establishment_group_type_id)))
    WHERE (egroups.status <> 2);
  SQL
  create_view "support_case_searches", sql_definition: <<-SQL
      SELECT sc.id AS case_id,
      sc.ref AS case_ref,
      sc.created_at,
      sc.updated_at,
      sc.state AS case_state,
      sc.email,
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
  create_view "support_case_data", sql_definition: <<-SQL
      SELECT sc.id AS case_id,
      sc.ref AS case_ref,
      sc.created_at,
      GREATEST(sc.updated_at, si.created_at) AS last_modified_at,
      sc.source AS case_source,
      sc.state AS case_state,
      sc.closure_reason AS case_closure_reason,
      cat.title AS sub_category_title,
      sc.savings_actual,
      sc.savings_actual_method,
      sc.savings_estimate,
      sc.savings_estimate_method,
      sc.savings_status,
      sc.support_level AS case_support_level,
      sc.value AS case_value,
      se.name AS organisation_name,
      se.urn AS organisation_urn,
      se.ukprn AS organisation_ukprn,
      se.rsc_region AS organisation_rsc_region,
      se.local_authority_name AS organisation_local_authority_name,
      se.local_authority_code AS organisation_local_authority_code,
      se.uid AS organisation_uid,
      se.phase AS organisation_phase,
      se.organisation_status,
      se.egroup_status AS establishment_group_status,
      se.establishment_type,
      sf.name AS framework_name,
      sp.reason_for_route_to_market,
      sp.required_agreement_type,
      sp.route_to_market,
      sp.stage AS procurement_stage,
      sp.started_at AS procurement_started_at,
      sp.ended_at AS procurement_ended_at,
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
      ps.created_at AS participation_survey_date,
      es.created_at AS exit_survey_date,
      sir.referrer
     FROM ((((((((((support_cases sc
       LEFT JOIN support_interactions si ON ((si.id = ( SELECT i.id
             FROM support_interactions i
            WHERE (i.case_id = sc.id)
            ORDER BY i.created_at
           LIMIT 1))))
       LEFT JOIN ( SELECT organisations.id,
              organisations.name,
              organisations.rsc_region,
              (organisations.local_authority ->> 'name'::text) AS local_authority_name,
              (organisations.local_authority ->> 'code'::text) AS local_authority_code,
              organisations.urn,
              organisations.ukprn,
              organisations.status AS organisation_status,
              NULL::integer AS egroup_status,
              NULL::character varying AS uid,
              organisations.phase,
              etypes.name AS establishment_type,
              'Support::Organisation'::text AS source
             FROM (support_organisations organisations
               JOIN support_establishment_types etypes ON ((etypes.id = organisations.establishment_type_id)))
          UNION ALL
           SELECT egroups.id,
              egroups.name,
              NULL::character varying AS rsc_region,
              NULL::text AS local_authority_name,
              NULL::text AS local_authority_code,
              NULL::character varying AS urn,
              egroups.ukprn,
              NULL::integer AS organisation_status,
              egroups.status AS egroup_status,
              egroups.uid,
              NULL::integer AS phase,
              egtypes.name AS establishment_type,
              'Support::EstablishmentGroup'::text AS source
             FROM (support_establishment_groups egroups
               JOIN support_establishment_group_types egtypes ON ((egtypes.id = egroups.establishment_group_type_id)))) se ON (((sc.organisation_id = se.id) AND ((sc.organisation_type)::text = se.source))))
       LEFT JOIN support_categories cat ON ((sc.category_id = cat.id)))
       LEFT JOIN support_procurements sp ON ((sc.procurement_id = sp.id)))
       LEFT JOIN support_frameworks sf ON ((sp.framework_id = sf.id)))
       LEFT JOIN support_contracts ec ON ((sc.existing_contract_id = ec.id)))
       LEFT JOIN support_contracts nc ON ((sc.existing_contract_id = nc.id)))
       LEFT JOIN ( SELECT si_1.created_at,
              si_1.case_id
             FROM support_interactions si_1
            WHERE ((si_1.event_type = 3) AND ((si_1.additional_data ->> 'email_template'::text) = 'fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779'::text))) ps ON ((si.case_id = ps.case_id)))
       LEFT JOIN ( SELECT si_1.created_at,
              si_1.case_id
             FROM support_interactions si_1
            WHERE ((si_1.event_type = 3) AND ((si_1.additional_data ->> 'email_template'::text) = '134bc268-2c6b-4b74-b6f4-4a58e22d6c8b'::text))) es ON ((si.case_id = es.case_id)))
       LEFT JOIN ( SELECT (si_1.additional_data ->> 'referrer'::text) AS referrer,
              si_1.case_id
             FROM support_interactions si_1
            WHERE (si_1.event_type = 8)) sir ON ((si.case_id = sir.case_id)));
  SQL
  create_view "support_message_threads", sql_definition: <<-SQL
      SELECT DISTINCT ON (se.outlook_conversation_id, se.case_id) se.outlook_conversation_id AS conversation_id,
      se.case_id,
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
  create_view "support_tower_cases", sql_definition: <<-SQL
      SELECT sc.id,
      sc.state,
      sc.value,
      sc.procurement_id,
      COALESCE(sp.stage, 99) AS procurement_stage,
      COALESCE(sc.support_level, 99) AS support_level,
      COALESCE(tow.title, 'No Tower'::character varying) AS tower_name,
      lower(replace((COALESCE(tow.title, 'No Tower'::character varying))::text, ' '::text, '-'::text)) AS tower_slug,
      tow.id AS tower_id,
      sc.created_at,
      sc.updated_at
     FROM (((support_cases sc
       JOIN support_procurements sp ON ((sp.id = sc.procurement_id)))
       LEFT JOIN support_categories cat ON ((sc.category_id = cat.id)))
       LEFT JOIN support_towers tow ON ((cat.support_tower_id = tow.id)))
    WHERE (sc.state = ANY (ARRAY[0, 1, 3]));
  SQL
end
