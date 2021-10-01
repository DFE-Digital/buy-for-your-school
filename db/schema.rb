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

ActiveRecord::Schema.define(version: 2021_09_21_115522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activity_log", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "journey_id"
    t.string "user_id"
    t.string "contentful_category_id"
    t.string "contentful_section_id"
    t.string "contentful_task_id"
    t.string "contentful_step_id"
    t.string "action"
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "journeys_count"
    t.string "slug"
    t.index ["contentful_id"], name: "index_categories_on_contentful_id", unique: true
  end

  create_table "checkbox_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "further_information"
    t.boolean "skipped", default: false
    t.index ["step_id"], name: "index_checkbox_answers_on_step_id"
  end

  create_table "currency_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.decimal "response", precision: 11, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_currency_answers_on_step_id"
  end

  create_table "journeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id"
    t.boolean "started", default: false
    t.uuid "category_id"
    t.integer "state", default: 0
    t.index ["category_id"], name: "index_journeys_on_category_id"
    t.index ["started"], name: "index_journeys_on_started"
    t.index ["user_id"], name: "index_journeys_on_user_id"
  end

  create_table "long_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.text "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_long_text_answers_on_step_id"
  end

  create_table "number_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.integer "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_number_answers_on_step_id"
  end

  create_table "radio_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "further_information"
    t.index ["step_id"], name: "index_radio_answers_on_step_id"
  end

  create_table "sections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "journey_id"
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "contentful_id"
    t.integer "order"
    t.index ["journey_id"], name: "index_sections_on_journey_id"
    t.index ["order"], name: "index_sections_on_order"
  end

  create_table "short_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_short_text_answers_on_step_id"
  end

  create_table "single_date_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.date "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_single_date_answers_on_step_id"
  end

  create_table "steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "help_text"
    t.string "contentful_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "support_agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dsi_uid", default: "", null: false
    t.string "email", default: "", null: false
    t.index ["dsi_uid"], name: "index_support_agents_on_dsi_uid"
    t.index ["email"], name: "index_support_agents_on_email"
  end

  create_table "support_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ref"
    t.uuid "category_id"
    t.string "sub_category_string"
    t.string "request_text"
    t.integer "support_level"
    t.integer "status"
    t.integer "state", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "agent_id"
    t.index ["category_id"], name: "index_support_cases_on_category_id"
    t.index ["ref"], name: "index_support_cases_on_ref", unique: true
    t.index ["state"], name: "index_support_cases_on_state"
    t.index ["status"], name: "index_support_cases_on_status"
    t.index ["support_level"], name: "index_support_cases_on_support_level"
  end

  create_table "support_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "slug"
    t.string "description"
    t.index ["slug"], name: "index_support_categories_on_slug", unique: true
    t.index ["title"], name: "index_support_categories_on_title", unique: true
  end

  create_table "support_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.string "document_body"
    t.string "documentable_type", null: false
    t.uuid "documentable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["documentable_id"], name: "index_support_documents_on_documentable_id"
    t.index ["documentable_type"], name: "index_support_documents_on_documentable_type"
  end

  create_table "support_enquiries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "support_request_id"
    t.uuid "case_id"
    t.string "name"
    t.string "email"
    t.string "telephone"
    t.string "school_urn"
    t.string "school_name"
    t.string "category"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["case_id"], name: "index_support_enquiries_on_case_id"
    t.index ["support_request_id"], name: "index_support_enquiries_on_support_request_id"
  end

  create_table "support_interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id"
    t.uuid "case_id"
    t.integer "event_type"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["agent_id"], name: "index_support_interactions_on_agent_id"
    t.index ["case_id"], name: "index_support_interactions_on_case_id"
    t.index ["event_type"], name: "index_support_interactions_on_event_type"
  end

  create_table "support_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_id"
    t.uuid "journey_id"
    t.uuid "category_id"
    t.string "message"
    t.string "school_name"
    t.string "school_urn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone_number"
    t.index ["category_id"], name: "index_support_requests_on_category_id"
    t.index ["journey_id"], name: "index_support_requests_on_journey_id"
    t.index ["user_id"], name: "index_support_requests_on_user_id"
  end

  create_table "support_sub_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "title", null: false
    t.string "description"
    t.string "slug"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["slug"], name: "index_support_sub_categories_on_slug", unique: true
    t.index ["title"], name: "index_support_sub_categories_on_title", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "section_id"
    t.string "title", null: false
    t.string "contentful_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order"
    t.jsonb "step_tally", default: "{}"
    t.text "statement_ids", default: [], null: false, array: true
    t.text "skipped_ids", default: [], null: false, array: true
    t.index ["order"], name: "index_tasks_on_order"
    t.index ["section_id"], name: "index_tasks_on_section_id"
    t.index ["skipped_ids"], name: "index_tasks_on_skipped_ids", using: :gin
    t.index ["statement_ids"], name: "index_tasks_on_statement_ids"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "dfe_sign_in_uid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.jsonb "orgs"
    t.jsonb "roles"
    t.index ["email"], name: "index_users_on_email"
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["last_name"], name: "index_users_on_last_name"
  end

  add_foreign_key "long_text_answers", "steps", on_delete: :cascade
  add_foreign_key "radio_answers", "steps", on_delete: :cascade
  add_foreign_key "short_text_answers", "steps", on_delete: :cascade
end
