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

ActiveRecord::Schema[8.0].define(version: 2025_09_04_185945) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.string "address_type", default: "primary", null: false
    t.string "zip_code", null: false
    t.string "street", null: false
    t.string "number"
    t.string "complement"
    t.string "neighborhood", null: false
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id", "address_type"], name: "index_addresses_on_addressable_and_type"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["latitude", "longitude"], name: "index_addresses_on_coordinates"
    t.index ["state"], name: "index_addresses_on_state"
    t.index ["zip_code"], name: "index_addresses_on_zip_code"
  end

  create_table "agenda_professionals", force: :cascade do |t|
    t.bigint "agenda_id", null: false
    t.bigint "professional_id", null: false
    t.integer "capacity_per_slot", default: 1
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_agenda_professionals_on_active"
    t.index ["agenda_id", "professional_id"], name: "index_agenda_professionals_on_agenda_id_and_professional_id", unique: true
    t.index ["agenda_id"], name: "index_agenda_professionals_on_agenda_id"
    t.index ["professional_id"], name: "index_agenda_professionals_on_professional_id"
    t.index ["professional_id"], name: "index_agenda_professionals_on_professional_id_unique"
  end

  create_table "agendas", force: :cascade do |t|
    t.string "name", null: false
    t.integer "service_type", default: 0, null: false
    t.integer "default_visibility", default: 0, null: false
    t.bigint "unit_id"
    t.string "color_theme", default: "#3B82F6"
    t.text "notes"
    t.json "working_hours", default: {}, null: false
    t.integer "slot_duration_minutes", default: 50, null: false
    t.integer "buffer_minutes", default: 10, null: false
    t.integer "status", default: 0, null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id"
    t.integer "lock_version", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_agendas_on_created_by_id"
    t.index ["name", "unit_id", "service_type"], name: "index_agendas_unique_name_per_unit_type", unique: true
    t.index ["service_type"], name: "index_agendas_on_service_type"
    t.index ["status"], name: "index_agendas_on_status"
    t.index ["unit_id"], name: "index_agendas_on_unit_id"
    t.index ["updated_by_id"], name: "index_agendas_on_updated_by_id"
  end

  create_table "contract_types", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "requires_company", default: false, null: false
    t.boolean "requires_cnpj", default: false, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.index ["name"], name: "index_contract_types_on_name", unique: true
  end

  create_table "document_permissions", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "group_id"
    t.integer "access_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_id"
    t.index ["access_level"], name: "index_document_permissions_on_access_level"
    t.index ["document_id", "group_id"], name: "index_document_permissions_on_document_id_and_group_id", unique: true, where: "(group_id IS NOT NULL)"
    t.index ["document_id", "professional_id"], name: "index_document_permissions_on_document_id_and_professional_id", unique: true, where: "(professional_id IS NOT NULL)"
    t.index ["document_id"], name: "index_document_permissions_on_document_id"
    t.index ["group_id"], name: "index_document_permissions_on_group_id"
    t.index ["professional_id"], name: "index_document_permissions_on_professional_id"
    t.check_constraint "professional_id IS NOT NULL OR group_id IS NOT NULL", name: "check_professional_or_group_present"
  end

  create_table "document_releases", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "version_id", null: false
    t.datetime "released_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "released_by_professional_id", null: false
    t.index ["document_id"], name: "index_document_releases_on_document_id"
    t.index ["released_by_professional_id"], name: "index_document_releases_on_released_by_professional_id"
    t.index ["version_id"], name: "index_document_releases_on_version_id"
  end

  create_table "document_responsibles", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_id", null: false
    t.index ["document_id"], name: "index_document_responsibles_on_document_id"
    t.index ["professional_id"], name: "index_document_responsibles_on_professional_id"
  end

  create_table "document_status_logs", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.integer "old_status"
    t.integer "new_status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_id", null: false
    t.index ["document_id"], name: "index_document_status_logs_on_document_id"
    t.index ["professional_id"], name: "index_document_status_logs_on_professional_id"
  end

  create_table "document_tasks", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_professional_id", null: false
    t.bigint "assigned_to_professional_id"
    t.bigint "completed_by_professional_id"
    t.index ["assigned_to_professional_id"], name: "index_document_tasks_on_assigned_to_professional_id"
    t.index ["completed_by_professional_id"], name: "index_document_tasks_on_completed_by_professional_id"
    t.index ["created_by_professional_id"], name: "index_document_tasks_on_created_by_professional_id"
    t.index ["document_id"], name: "index_document_tasks_on_document_id"
  end

  create_table "document_versions", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.string "version_number", null: false
    t.string "file_path", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_professional_id", null: false
    t.index ["created_by_professional_id"], name: "index_document_versions_on_created_by_professional_id"
    t.index ["document_id", "version_number"], name: "index_document_versions_on_document_id_and_version_number", unique: true
    t.index ["document_id"], name: "index_document_versions_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title", limit: 150, null: false
    t.text "description"
    t.integer "document_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "current_version", default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "released_version"
    t.bigint "author_professional_id", null: false
    t.integer "category", default: 0, null: false
    t.index ["author_professional_id"], name: "index_documents_on_author_professional_id"
    t.index ["category"], name: "index_documents_on_category"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["status"], name: "index_documents_on_status"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "event_type", default: 0, null: false
    t.integer "visibility_level", default: 0, null: false
    t.string "source_context"
    t.bigint "professional_id", null: false
    t.bigint "created_by_id", null: false
    t.string "resource_type"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["professional_id", "event_type"], name: "index_events_on_professional_id_and_event_type"
    t.index ["professional_id", "start_time", "end_time"], name: "index_events_on_professional_id_and_start_time_and_end_time"
    t.index ["professional_id", "visibility_level"], name: "index_events_on_professional_id_and_visibility_level"
    t.index ["professional_id"], name: "index_events_on_professional_id"
    t.index ["resource_type"], name: "index_events_on_resource_type"
    t.index ["source_context"], name: "index_events_on_source_context"
    t.index ["start_time", "end_time"], name: "index_events_on_start_time_and_end_time"
    t.check_constraint "end_time > start_time", name: "check_end_time_after_start_time"
  end

  create_table "external_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "company_name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_external_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_external_users_on_reset_password_token", unique: true
  end

  create_table "group_permissions", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "permission_id"], name: "index_group_permissions_on_group_id_and_permission_id", unique: true
    t.index ["group_id"], name: "index_group_permissions_on_group_id"
    t.index ["permission_id"], name: "index_group_permissions_on_permission_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "confirmed_at"
    t.integer "attempts_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_invites_on_expires_at"
    t.index ["token"], name: "index_invites_on_token", unique: true
    t.index ["user_id"], name: "index_invites_on_user_id"
  end

  create_table "journey_events", force: :cascade do |t|
    t.bigint "portal_intake_id", null: false
    t.string "event_type", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_journey_events_on_created_at"
    t.index ["event_type"], name: "index_journey_events_on_event_type"
    t.index ["portal_intake_id"], name: "index_journey_events_on_portal_intake_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "key", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "portal_intakes", force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.string "beneficiary_name", null: false
    t.string "plan_name", null: false
    t.string "card_code", null: false
    t.string "status", default: "aguardando_agendamento_anamnese", null: false
    t.datetime "requested_at", null: false
    t.date "anamnesis_scheduled_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anamnesis_scheduled_on"], name: "index_portal_intakes_on_anamnesis_scheduled_on"
    t.index ["operator_id"], name: "index_portal_intakes_on_operator_id"
    t.index ["requested_at"], name: "index_portal_intakes_on_requested_at"
    t.index ["status"], name: "index_portal_intakes_on_status"
  end

  create_table "professional_groups", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_professional_groups_on_group_id"
    t.index ["professional_id", "group_id"], name: "index_professional_groups_on_professional_id_and_group_id", unique: true
    t.index ["professional_id"], name: "index_professional_groups_on_professional_id"
  end

  create_table "professional_specialities", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "speciality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id", "speciality_id"], name: "index_professional_specialities_unique", unique: true
    t.index ["professional_id"], name: "index_professional_specialities_on_professional_id"
    t.index ["speciality_id"], name: "index_professional_specialities_on_speciality_id"
  end

  create_table "professional_specializations", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "specialization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id", "specialization_id"], name: "index_professional_specializations_unique", unique: true
    t.index ["professional_id"], name: "index_professional_specializations_on_professional_id"
    t.index ["specialization_id"], name: "index_professional_specializations_on_specialization_id"
  end

  create_table "professionals", force: :cascade do |t|
    t.string "full_name", null: false
    t.date "birth_date"
    t.string "cpf", null: false
    t.string "phone"
    t.string "email", null: false
    t.boolean "active", default: true, null: false
    t.bigint "contract_type_id"
    t.date "hired_on"
    t.integer "workload_minutes", default: 0, null: false
    t.string "council_code"
    t.string "company_name"
    t.string "cnpj"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "system_permissions", default: [], array: true
    t.index ["contract_type_id"], name: "index_professionals_on_contract_type_id"
    t.index ["cpf"], name: "index_professionals_on_cpf", unique: true
    t.index ["email"], name: "index_professionals_on_email", unique: true
    t.index ["system_permissions"], name: "index_professionals_on_system_permissions", using: :gin
  end

  create_table "service_request_referrals", force: :cascade do |t|
    t.bigint "service_request_id", null: false
    t.string "cid", null: false
    t.string "encaminhado_para", null: false
    t.string "medico", null: false
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "medico_crm"
    t.date "data_encaminhamento"
    t.index ["encaminhado_para"], name: "index_service_request_referrals_on_encaminhado_para"
    t.index ["service_request_id"], name: "index_service_request_referrals_on_service_request_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.bigint "external_user_id", null: false
    t.string "convenio", null: false
    t.string "carteira_codigo", null: false
    t.string "tipo_convenio", null: false
    t.string "nome", null: false
    t.date "data_encaminhamento", null: false
    t.string "status", default: "aguardando", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "telefone_responsavel", null: false
    t.index ["data_encaminhamento"], name: "index_service_requests_on_data_encaminhamento"
    t.index ["external_user_id"], name: "index_service_requests_on_external_user_id"
    t.index ["status"], name: "index_service_requests_on_status"
  end

  create_table "specialities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.string "specialty", default: "", null: false
    t.index ["name"], name: "index_specialities_on_name", unique: true
  end

  create_table "specialization_specialities", force: :cascade do |t|
    t.bigint "specialization_id", null: false
    t.bigint "speciality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speciality_id"], name: "index_specialization_specialities_on_speciality_id"
    t.index ["specialization_id", "speciality_id"], name: "index_spec_spec_on_spec_id_and_spec_id", unique: true
    t.index ["specialization_id"], name: "index_specialization_specialities_on_specialization_id"
  end

  create_table "specializations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_specializations_on_name", unique: true
  end

  create_table "units", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_units_on_active"
    t.index ["name"], name: "index_units_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "active", default: true, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.bigint "professional_id", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["professional_id"], name: "index_users_on_professional_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "version_comments", force: :cascade do |t|
    t.bigint "document_version_id", null: false
    t.bigint "user_id", null: false
    t.text "comment_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_version_comments_on_created_at"
    t.index ["document_version_id"], name: "index_version_comments_on_document_version_id"
    t.index ["user_id"], name: "index_version_comments_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agenda_professionals", "agendas"
  add_foreign_key "agenda_professionals", "users", column: "professional_id"
  add_foreign_key "agendas", "units"
  add_foreign_key "agendas", "users", column: "created_by_id"
  add_foreign_key "agendas", "users", column: "updated_by_id"
  add_foreign_key "document_permissions", "documents"
  add_foreign_key "document_permissions", "groups"
  add_foreign_key "document_permissions", "professionals"
  add_foreign_key "document_releases", "document_versions", column: "version_id"
  add_foreign_key "document_releases", "documents"
  add_foreign_key "document_releases", "professionals", column: "released_by_professional_id"
  add_foreign_key "document_responsibles", "documents"
  add_foreign_key "document_responsibles", "professionals"
  add_foreign_key "document_status_logs", "documents"
  add_foreign_key "document_status_logs", "professionals"
  add_foreign_key "document_tasks", "documents"
  add_foreign_key "document_tasks", "professionals", column: "assigned_to_professional_id"
  add_foreign_key "document_tasks", "professionals", column: "completed_by_professional_id"
  add_foreign_key "document_tasks", "professionals", column: "created_by_professional_id"
  add_foreign_key "document_versions", "documents"
  add_foreign_key "document_versions", "professionals", column: "created_by_professional_id"
  add_foreign_key "documents", "professionals", column: "author_professional_id"
  add_foreign_key "events", "professionals"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "group_permissions", "groups"
  add_foreign_key "group_permissions", "permissions"
  add_foreign_key "invites", "users"
  add_foreign_key "journey_events", "portal_intakes"
  add_foreign_key "portal_intakes", "external_users", column: "operator_id"
  add_foreign_key "professional_groups", "groups"
  add_foreign_key "professional_groups", "professionals"
  add_foreign_key "professional_specialities", "professionals"
  add_foreign_key "professional_specialities", "specialities"
  add_foreign_key "professional_specializations", "professionals"
  add_foreign_key "professional_specializations", "specializations"
  add_foreign_key "professionals", "contract_types"
  add_foreign_key "service_request_referrals", "service_requests"
  add_foreign_key "service_requests", "external_users"
  add_foreign_key "specialization_specialities", "specialities"
  add_foreign_key "specialization_specialities", "specializations"
  add_foreign_key "users", "professionals"
  add_foreign_key "version_comments", "document_versions"
  add_foreign_key "version_comments", "users"
end
