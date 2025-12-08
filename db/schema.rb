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

ActiveRecord::Schema[8.0].define(version: 2025_12_02_120000) do
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

  create_table "agenda_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "category", default: 0, null: false
    t.integer "visibility", default: 0, null: false
    t.json "template_data", null: false
    t.integer "usage_count", default: 0
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_agenda_templates_on_category"
    t.index ["created_by_id", "visibility"], name: "index_agenda_templates_on_created_by_id_and_visibility"
    t.index ["created_by_id"], name: "index_agenda_templates_on_created_by_id"
    t.index ["usage_count"], name: "index_agenda_templates_on_usage_count"
    t.index ["visibility"], name: "index_agenda_templates_on_visibility"
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

  create_table "anamneses", force: :cascade do |t|
    t.bigint "beneficiary_id"
    t.bigint "professional_id", null: false
    t.bigint "portal_intake_id"
    t.datetime "performed_at", null: false
    t.string "father_name"
    t.date "father_birth_date"
    t.string "father_education"
    t.string "father_profession"
    t.string "mother_name"
    t.date "mother_birth_date"
    t.string "mother_education"
    t.string "mother_profession"
    t.string "responsible_name"
    t.date "responsible_birth_date"
    t.string "responsible_education"
    t.string "responsible_profession"
    t.boolean "attends_school", default: false
    t.string "school_name"
    t.string "school_period"
    t.string "referral_reason"
    t.boolean "injunction", default: false
    t.string "treatment_location"
    t.integer "referral_hours"
    t.json "specialties"
    t.boolean "diagnosis_completed", default: false
    t.string "responsible_doctor"
    t.boolean "previous_treatment", default: false
    t.json "previous_treatments"
    t.boolean "continue_external_treatment", default: false
    t.json "external_treatments"
    t.json "preferred_schedule"
    t.json "unavailable_schedule"
    t.string "status", default: "pendente"
    t.bigint "created_by_professional_id"
    t.bigint "updated_by_professional_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attendance_status", default: "scheduled"
    t.datetime "attended_at"
    t.datetime "no_show_at"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.text "no_show_reason"
    t.time "start_time"
    t.string "session_email"
    t.string "birthplace"
    t.string "birth_state"
    t.string "religion"
    t.string "father_cpf"
    t.string "father_workplace"
    t.string "mother_cpf"
    t.string "mother_workplace"
    t.json "family_composition"
    t.text "main_complaint"
    t.text "complaint_noticed_since"
    t.boolean "pregnancy_planned"
    t.boolean "prenatal_care"
    t.integer "mother_age_at_birth"
    t.boolean "had_miscarriages"
    t.integer "miscarriages_count"
    t.string "miscarriages_type"
    t.boolean "pregnancy_trauma"
    t.boolean "pregnancy_illness"
    t.string "pregnancy_illness_description"
    t.boolean "pregnancy_medication"
    t.string "pregnancy_medication_description"
    t.boolean "pregnancy_drugs"
    t.string "pregnancy_drugs_description"
    t.boolean "pregnancy_alcohol"
    t.boolean "pregnancy_smoking"
    t.integer "cigarettes_per_day"
    t.string "birth_type"
    t.string "birth_location_type"
    t.string "birth_term"
    t.boolean "had_anesthesia"
    t.string "anesthesia_type"
    t.string "baby_position"
    t.boolean "cried_at_birth"
    t.integer "apgar_1min"
    t.integer "apgar_5min"
    t.integer "mother_hospital_days"
    t.integer "baby_hospital_days"
    t.decimal "birth_weight", precision: 5, scale: 3
    t.decimal "birth_height", precision: 5, scale: 2
    t.boolean "needed_incubator"
    t.boolean "needed_icu"
    t.text "icu_reason"
    t.text "birth_complications"
    t.text "baby_health"
    t.text "respiratory_problems"
    t.text "general_behavior_baby"
    t.boolean "breastfed"
    t.string "breastfed_until"
    t.boolean "bottle_fed"
    t.string "bottle_fed_until"
    t.text "feeding_contact"
    t.boolean "daily_meals"
    t.text "favorite_foods"
    t.text "rejected_foods"
    t.boolean "frequent_vomiting"
    t.text "meal_behavior"
    t.boolean "fixed_meal_schedule"
    t.boolean "eats_alone"
    t.boolean "chewing_difficulty"
    t.boolean "drools"
    t.string "drools_when"
    t.text "feeding_notes"
    t.boolean "held_head"
    t.string "held_head_age"
    t.boolean "rolled_over"
    t.boolean "rolled_bilateral"
    t.text "rolled_notes"
    t.boolean "sat_unsupported"
    t.string "sat_unsupported_age"
    t.boolean "crawled"
    t.string "crawled_age"
    t.text "crawled_how"
    t.string "stood_age"
    t.string "walked_age"
    t.boolean "climbed_stairs"
    t.string "climbed_stairs_age"
    t.boolean "squatted"
    t.string "squatted_age"
    t.boolean "used_walker"
    t.string "used_walker_age"
    t.boolean "motor_coordination_problem"
    t.text "motor_coordination_description"
    t.boolean "object_manipulation_difficulty"
    t.string "bladder_control_day"
    t.string "bladder_control_night"
    t.string "bowel_control_day"
    t.string "bowel_control_night"
    t.boolean "babbled"
    t.string "babbled_age"
    t.string "speech_started_age"
    t.boolean "understandable_speech"
    t.string "understandable_since"
    t.boolean "speech_difficulties"
    t.text "speech_difficulties_description"
    t.boolean "echolalia"
    t.boolean "hearing_problems"
    t.text "hearing_problems_description"
    t.boolean "responds_from_distance"
    t.boolean "easily_startled"
    t.boolean "uses_gestures"
    t.text "gestures_description"
    t.boolean "uses_other_as_tool"
    t.boolean "words_in_context"
    t.boolean "shares_interests"
    t.boolean "stopped_speaking"
    t.string "stopped_speaking_when"
    t.boolean "understands_speech"
    t.text "communicates_desires"
    t.text "reaction_not_understood"
    t.text "family_reaction_communication"
    t.boolean "sleep_routine"
    t.text "sleep_routine_description"
    t.boolean "individual_bed"
    t.text "individual_bed_description"
    t.text "sleep_quality"
    t.boolean "nocturnal_enuresis"
    t.text "preferred_play"
    t.text "how_plays"
    t.text "protective_reaction_play"
    t.text "favorite_toys"
    t.boolean "watches_tv"
    t.text "watches_tv_how"
    t.text "favorite_programs"
    t.boolean "watches_repeatedly"
    t.boolean "plays_with_others"
    t.text "plays_with_others_how"
    t.text "fights_with_peers"
    t.boolean "defends_from_aggression"
    t.text "defense_method"
    t.text "reaction_prohibitions"
    t.text "behavior_with_strangers"
    t.boolean "danger_awareness"
    t.text "danger_awareness_description"
    t.text "new_situations_reaction"
    t.boolean "obeys_orders"
    t.text "shows_affection"
    t.boolean "aggressive_behavior"
    t.text "aggressive_behavior_description"
    t.text "family_crisis_reaction"
    t.string "school_phone"
    t.string "school_enrollment_age"
    t.boolean "has_support_teacher"
    t.text "after_school_activities"
    t.text "school_difficulties"
    t.text "family_school_expectations"
    t.text "previous_illnesses"
    t.boolean "hospitalizations"
    t.text "hospitalization_causes"
    t.boolean "has_epilepsy"
    t.string "epilepsy_frequency"
    t.text "current_medications"
    t.text "exams_done"
    t.text "exams_to_do"
    t.boolean "has_allergies"
    t.text "allergies_description"
    t.json "family_conditions"
    t.boolean "psychiatric_hospitalization"
    t.string "psychiatric_hospitalization_who"
    t.text "general_information"
    t.boolean "cord_around_neck"
    t.boolean "cyanotic"
    t.index ["attendance_status"], name: "index_anamneses_on_attendance_status"
    t.index ["beneficiary_id", "status"], name: "index_anamneses_on_beneficiary_id_and_status"
    t.index ["beneficiary_id"], name: "index_anamneses_on_beneficiary_id"
    t.index ["created_at"], name: "index_anamneses_on_created_at"
    t.index ["created_by_professional_id"], name: "index_anamneses_on_created_by_professional_id"
    t.index ["performed_at"], name: "index_anamneses_on_performed_at"
    t.index ["portal_intake_id"], name: "index_anamneses_on_portal_intake_id"
    t.index ["professional_id", "performed_at"], name: "index_anamneses_on_professional_id_and_performed_at"
    t.index ["professional_id"], name: "index_anamneses_on_professional_id"
    t.index ["status"], name: "index_anamneses_on_status"
    t.index ["updated_by_professional_id"], name: "index_anamneses_on_updated_by_professional_id"
  end

  create_table "appointment_attachments", force: :cascade do |t|
    t.bigint "medical_appointment_id", null: false
    t.bigint "uploaded_by_id", null: false
    t.string "attachment_type", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachment_type"], name: "index_appointment_attachments_on_attachment_type"
    t.index ["medical_appointment_id", "created_at"], name: "idx_on_medical_appointment_id_created_at_17577c0f7b"
    t.index ["medical_appointment_id"], name: "index_appointment_attachments_on_medical_appointment_id"
    t.index ["uploaded_by_id"], name: "index_appointment_attachments_on_uploaded_by_id"
  end

  create_table "appointment_notes", force: :cascade do |t|
    t.bigint "medical_appointment_id", null: false
    t.bigint "created_by_id", null: false
    t.string "note_type", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_appointment_notes_on_created_by_id"
    t.index ["medical_appointment_id", "created_at"], name: "idx_on_medical_appointment_id_created_at_e8ef50653d"
    t.index ["medical_appointment_id"], name: "index_appointment_notes_on_medical_appointment_id"
    t.index ["note_type"], name: "index_appointment_notes_on_note_type"
  end

  create_table "availability_exceptions", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "agenda_id"
    t.date "exception_date", null: false
    t.integer "exception_type", null: false
    t.time "start_time"
    t.time "end_time"
    t.text "reason"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agenda_id"], name: "index_availability_exceptions_on_agenda_id"
    t.index ["exception_type"], name: "index_availability_exceptions_on_exception_type"
    t.index ["professional_id", "exception_date"], name: "idx_on_professional_id_exception_date_9761fb9ff6"
    t.index ["professional_id"], name: "index_availability_exceptions_on_professional_id"
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.bigint "portal_intake_id"
    t.bigint "created_by_professional_id"
    t.bigint "updated_by_professional_id"
    t.string "name", null: false
    t.date "birth_date", null: false
    t.string "cpf", null: false
    t.string "phone"
    t.string "secondary_phone"
    t.string "email"
    t.string "secondary_email"
    t.string "whatsapp_number"
    t.text "address"
    t.string "address_number"
    t.string "address_complement"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "address_reference"
    t.string "responsible_name"
    t.string "responsible_phone"
    t.string "relationship"
    t.string "responsible_cpf"
    t.string "responsible_rg"
    t.string "responsible_profession"
    t.decimal "family_income", precision: 10, scale: 2
    t.boolean "attends_school", default: false
    t.string "school_name"
    t.string "school_period"
    t.string "health_plan"
    t.string "health_card_number"
    t.text "allergies"
    t.text "continuous_medications"
    t.text "special_conditions"
    t.string "integrar_code", null: false
    t.string "medical_record_number"
    t.string "photo"
    t.string "status", default: "ativo"
    t.date "treatment_start_date"
    t.date "treatment_end_date"
    t.text "inactivation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["birth_date"], name: "index_beneficiaries_on_birth_date"
    t.index ["cpf"], name: "index_beneficiaries_on_cpf", unique: true
    t.index ["created_at"], name: "index_beneficiaries_on_created_at"
    t.index ["created_by_professional_id"], name: "index_beneficiaries_on_created_by_professional_id"
    t.index ["integrar_code"], name: "index_beneficiaries_on_integrar_code", unique: true
    t.index ["medical_record_number"], name: "index_beneficiaries_on_medical_record_number", unique: true
    t.index ["name"], name: "index_beneficiaries_on_name"
    t.index ["portal_intake_id"], name: "index_beneficiaries_on_portal_intake_id"
    t.index ["status"], name: "index_beneficiaries_on_status"
    t.index ["updated_by_professional_id"], name: "index_beneficiaries_on_updated_by_professional_id"
  end

  create_table "beneficiary_chat_message_reads", force: :cascade do |t|
    t.bigint "beneficiary_chat_message_id", null: false
    t.bigint "user_id", null: false
    t.datetime "read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_chat_message_id", "user_id"], name: "index_bcm_reads_on_message_and_user", unique: true
    t.index ["beneficiary_chat_message_id"], name: "idx_on_beneficiary_chat_message_id_33d0f29442"
    t.index ["read_at"], name: "index_beneficiary_chat_message_reads_on_read_at"
    t.index ["user_id"], name: "index_beneficiary_chat_message_reads_on_user_id"
  end

  create_table "beneficiary_chat_messages", force: :cascade do |t|
    t.bigint "beneficiary_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "chat_group", default: "professionals_only", null: false
    t.index ["beneficiary_id", "chat_group", "created_at"], name: "idx_bcm_beneficiary_group_created_desc", order: { created_at: :desc }
    t.index ["beneficiary_id", "chat_group", "created_at"], name: "idx_on_beneficiary_id_chat_group_created_at_db9ed02f8e"
    t.index ["beneficiary_id", "created_at"], name: "idx_on_beneficiary_id_created_at_80b2cd8f42"
    t.index ["beneficiary_id"], name: "index_beneficiary_chat_messages_on_beneficiary_id"
    t.index ["user_id", "created_at"], name: "idx_bcm_sender_created_desc", order: { created_at: :desc }
    t.index ["user_id"], name: "index_beneficiary_chat_messages_on_user_id"
  end

  create_table "beneficiary_professionals", force: :cascade do |t|
    t.bigint "beneficiary_id", null: false
    t.bigint "professional_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id", "professional_id"], name: "index_beneficiary_professionals_unique", unique: true
    t.index ["beneficiary_id"], name: "index_beneficiary_professionals_on_beneficiary_id"
    t.index ["professional_id"], name: "index_beneficiary_professionals_on_professional_id"
  end

  create_table "beneficiary_tickets", force: :cascade do |t|
    t.bigint "beneficiary_id", null: false
    t.bigint "assigned_professional_id"
    t.bigint "created_by_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_professional_id"], name: "index_beneficiary_tickets_on_assigned_professional_id"
    t.index ["beneficiary_id", "status"], name: "index_beneficiary_tickets_on_beneficiary_id_and_status"
    t.index ["beneficiary_id"], name: "index_beneficiary_tickets_on_beneficiary_id"
    t.index ["created_by_id"], name: "index_beneficiary_tickets_on_created_by_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "message_number", null: false
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.integer "content_type", default: 0, null: false
    t.text "body", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "edited_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dedupe_key"
    t.index ["conversation_id", "created_at"], name: "idx_chat_messages_conversation_created_desc", order: { created_at: :desc }, where: "(deleted_at IS NULL)"
    t.index ["conversation_id", "message_number"], name: "idx_chat_messages_conversation_number_unique", unique: true
    t.index ["conversation_id"], name: "index_chat_messages_on_conversation_id"
    t.index ["dedupe_key"], name: "idx_chat_messages_dedupe_key_unique", unique: true, where: "(dedupe_key IS NOT NULL)"
    t.index ["sender_id", "created_at"], name: "idx_chat_messages_sender_created_desc", order: { created_at: :desc }
    t.check_constraint "content_type = ANY (ARRAY[0, 1, 2, 3, 4])", name: "check_content_type"
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

  create_table "conversation_participations", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "participant_type", null: false
    t.bigint "participant_id", null: false
    t.integer "role", default: 0, null: false
    t.bigint "last_read_message_number", default: 0, null: false
    t.integer "unread_count", default: 0, null: false
    t.boolean "notifications_enabled", default: true, null: false
    t.jsonb "notification_preferences", default: {}, null: false
    t.datetime "muted_until"
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "left_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "participant_id"], name: "idx_participations_conversation_participant_read"
    t.index ["conversation_id", "participant_type", "participant_id"], name: "idx_participations_conversation_participant_unique", unique: true, where: "(left_at IS NULL)"
    t.index ["conversation_id"], name: "index_conversation_participations_on_conversation_id"
    t.check_constraint "role = ANY (ARRAY[0, 1, 2, 3])", name: "check_role"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "service", null: false
    t.string "context_type", null: false
    t.bigint "context_id", null: false
    t.bigint "scope_id"
    t.string "scope"
    t.integer "conversation_type", default: 0, null: false
    t.bigint "next_message_number", default: 1, null: false
    t.bigint "messages_count", default: 0, null: false
    t.bigint "last_message_id"
    t.datetime "last_message_at"
    t.integer "status", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["context_type", "context_id", "status", "last_message_at"], name: "idx_conversations_context_status_last_message", order: { last_message_at: :desc }
    t.index ["context_type", "context_id"], name: "index_conversations_on_context_type_and_context_id"
    t.index ["identifier"], name: "index_conversations_on_identifier", unique: true
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["metadata"], name: "index_conversations_on_metadata", using: :gin
    t.index ["scope"], name: "index_conversations_on_scope"
    t.index ["scope_id"], name: "index_conversations_on_scope_id"
    t.index ["service", "updated_at"], name: "index_conversations_on_service_and_updated_at"
    t.index ["service"], name: "index_conversations_on_service"
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
    t.bigint "agenda_id"
    t.index ["agenda_id"], name: "index_events_on_agenda_id"
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

  create_table "flow_chart_versions", force: :cascade do |t|
    t.bigint "flow_chart_id", null: false
    t.integer "data_format", default: 0, null: false
    t.text "data"
    t.integer "version", null: false
    t.text "notes"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_flow_chart_versions_on_created_by_id"
    t.index ["flow_chart_id", "version"], name: "index_flow_chart_versions_on_flow_chart_id_and_version", unique: true
    t.index ["flow_chart_id"], name: "index_flow_chart_versions_on_flow_chart_id"
    t.index ["version"], name: "index_flow_chart_versions_on_version"
  end

  create_table "flow_charts", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.bigint "current_version_id"
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_flow_charts_on_created_by_id"
    t.index ["current_version_id"], name: "index_flow_charts_on_current_version_id"
    t.index ["status"], name: "index_flow_charts_on_status"
    t.index ["updated_by_id"], name: "index_flow_charts_on_updated_by_id"
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

  create_table "job_roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_job_roles_on_active"
    t.index ["name"], name: "index_job_roles_on_name", unique: true
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

  create_table "medical_appointments", force: :cascade do |t|
    t.bigint "agenda_id", null: false
    t.bigint "professional_id", null: false
    t.bigint "patient_id"
    t.string "appointment_type", null: false
    t.string "status", default: "scheduled", null: false
    t.string "priority", default: "normal", null: false
    t.datetime "scheduled_at", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.text "notes"
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.string "reschedule_reason"
    t.datetime "rescheduled_at"
    t.string "no_show_reason"
    t.datetime "no_show_at"
    t.text "completion_notes"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.bigint "anamnesis_id"
    t.index ["agenda_id"], name: "index_medical_appointments_on_agenda_id"
    t.index ["anamnesis_id"], name: "index_medical_appointments_on_anamnesis_id"
    t.index ["appointment_type"], name: "index_medical_appointments_on_appointment_type"
    t.index ["event_id"], name: "index_medical_appointments_on_event_id"
    t.index ["patient_id", "scheduled_at"], name: "index_medical_appointments_on_patient_id_and_scheduled_at"
    t.index ["patient_id"], name: "index_medical_appointments_on_patient_id"
    t.index ["priority"], name: "index_medical_appointments_on_priority"
    t.index ["professional_id", "scheduled_at"], name: "index_medical_appointments_on_professional_id_and_scheduled_at"
    t.index ["professional_id"], name: "index_medical_appointments_on_professional_id"
    t.index ["scheduled_at"], name: "index_medical_appointments_on_scheduled_at"
    t.index ["status"], name: "index_medical_appointments_on_status"
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.boolean "published"
    t.datetime "published_at"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "type", null: false
    t.boolean "email_enabled", default: true
    t.boolean "sms_enabled", default: false
    t.boolean "push_enabled", default: true
    t.json "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "type"], name: "index_notification_preferences_on_user_id_and_type", unique: true
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notification_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.string "channel", null: false
    t.string "subject"
    t.text "body", null: false
    t.json "variables"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_notification_templates_on_active"
    t.index ["type", "channel"], name: "index_notification_templates_on_type_and_channel"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.json "metadata"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.datetime "scheduled_at"
    t.string "status", default: "pending"
    t.string "channel", default: "email"
    t.datetime "sent_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["scheduled_at"], name: "index_notifications_on_scheduled_at"
    t.index ["type", "status"], name: "index_notifications_on_type_and_status"
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "key", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "portal_intake_referrals", force: :cascade do |t|
    t.bigint "portal_intake_id", null: false
    t.string "cid"
    t.string "encaminhado_para"
    t.string "medico"
    t.string "medico_crm"
    t.date "data_encaminhamento"
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portal_intake_id"], name: "index_portal_intake_referrals_on_portal_intake_id"
  end

  create_table "portal_intakes", force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.string "beneficiary_name", null: false
    t.string "plan_name", null: false
    t.string "card_code", null: false
    t.string "status", default: "aguardando_agendamento_anamnese", null: false
    t.datetime "requested_at", null: false
    t.datetime "anamnesis_scheduled_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "convenio"
    t.string "carteira_codigo"
    t.string "nome"
    t.string "telefone_responsavel"
    t.date "data_encaminhamento"
    t.date "data_nascimento"
    t.text "endereco"
    t.string "responsavel"
    t.string "tipo_convenio"
    t.string "cpf"
    t.date "data_recebimento_email"
    t.index ["anamnesis_scheduled_on"], name: "index_portal_intakes_on_anamnesis_scheduled_on"
    t.index ["data_recebimento_email"], name: "index_portal_intakes_on_data_recebimento_email"
    t.index ["operator_id"], name: "index_portal_intakes_on_operator_id"
    t.index ["requested_at"], name: "index_portal_intakes_on_requested_at"
    t.index ["status"], name: "index_portal_intakes_on_status"
  end

  create_table "professional_availabilities", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "agenda_id"
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.boolean "active", default: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_professional_availabilities_on_active"
    t.index ["agenda_id"], name: "index_professional_availabilities_on_agenda_id"
    t.index ["professional_id", "day_of_week"], name: "idx_on_professional_id_day_of_week_c89056fce6"
    t.index ["professional_id"], name: "index_professional_availabilities_on_professional_id"
  end

  create_table "professional_contracts", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.string "contract_type_enum"
    t.string "nationality"
    t.text "professional_formation"
    t.string "rg"
    t.string "cpf"
    t.string "council_registration_number"
    t.bigint "job_role_id"
    t.string "payment_type"
    t.decimal "monthly_value", precision: 10, scale: 2
    t.decimal "hourly_value", precision: 10, scale: 2
    t.decimal "overtime_hour_value", precision: 10, scale: 2, default: "17.0"
    t.string "company_cnpj"
    t.text "company_address"
    t.string "company_represented_by"
    t.string "ccm"
    t.text "taxpayer_address"
    t.string "contract_pdf_path"
    t.string "anexo_pdf_path"
    t.string "termo_pdf_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_type_enum"], name: "index_professional_contracts_on_contract_type_enum"
    t.index ["job_role_id"], name: "index_professional_contracts_on_job_role_id"
    t.index ["payment_type"], name: "index_professional_contracts_on_payment_type"
    t.index ["professional_id"], name: "index_professional_contracts_on_professional_id", unique: true
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

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.string "address"
    t.string "neighborhood"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code"
    t.string "phone"
    t.string "email"
    t.string "school_type"
    t.string "network"
    t.boolean "active", default: true, null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_schools_on_active"
    t.index ["city", "state"], name: "index_schools_on_city_and_state"
    t.index ["city"], name: "index_schools_on_city"
    t.index ["code"], name: "index_schools_on_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["state"], name: "index_schools_on_state"
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
  add_foreign_key "agenda_templates", "users", column: "created_by_id"
  add_foreign_key "agendas", "units"
  add_foreign_key "agendas", "users", column: "created_by_id"
  add_foreign_key "agendas", "users", column: "updated_by_id"
  add_foreign_key "anamneses", "beneficiaries"
  add_foreign_key "anamneses", "portal_intakes"
  add_foreign_key "anamneses", "users", column: "created_by_professional_id"
  add_foreign_key "anamneses", "users", column: "professional_id"
  add_foreign_key "anamneses", "users", column: "updated_by_professional_id"
  add_foreign_key "appointment_attachments", "medical_appointments"
  add_foreign_key "appointment_attachments", "users", column: "uploaded_by_id"
  add_foreign_key "appointment_notes", "medical_appointments"
  add_foreign_key "appointment_notes", "users", column: "created_by_id"
  add_foreign_key "availability_exceptions", "agendas"
  add_foreign_key "availability_exceptions", "professionals"
  add_foreign_key "beneficiaries", "portal_intakes"
  add_foreign_key "beneficiaries", "users", column: "created_by_professional_id"
  add_foreign_key "beneficiaries", "users", column: "updated_by_professional_id"
  add_foreign_key "beneficiary_chat_message_reads", "beneficiary_chat_messages"
  add_foreign_key "beneficiary_chat_message_reads", "users"
  add_foreign_key "beneficiary_chat_messages", "beneficiaries"
  add_foreign_key "beneficiary_chat_messages", "users"
  add_foreign_key "beneficiary_professionals", "beneficiaries"
  add_foreign_key "beneficiary_professionals", "professionals"
  add_foreign_key "beneficiary_tickets", "beneficiaries"
  add_foreign_key "beneficiary_tickets", "professionals", column: "assigned_professional_id"
  add_foreign_key "beneficiary_tickets", "users", column: "created_by_id"
  add_foreign_key "chat_messages", "conversations"
  add_foreign_key "conversation_participations", "conversations"
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
  add_foreign_key "events", "agendas"
  add_foreign_key "events", "professionals"
  add_foreign_key "events", "professionals", column: "created_by_id"
  add_foreign_key "flow_chart_versions", "flow_charts"
  add_foreign_key "group_permissions", "groups"
  add_foreign_key "group_permissions", "permissions"
  add_foreign_key "invites", "users"
  add_foreign_key "journey_events", "portal_intakes"
  add_foreign_key "medical_appointments", "agendas"
  add_foreign_key "medical_appointments", "anamneses", column: "anamnesis_id"
  add_foreign_key "medical_appointments", "events"
  add_foreign_key "medical_appointments", "professionals"
  add_foreign_key "medical_appointments", "users", column: "patient_id"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "portal_intake_referrals", "portal_intakes"
  add_foreign_key "portal_intakes", "external_users", column: "operator_id"
  add_foreign_key "professional_availabilities", "agendas"
  add_foreign_key "professional_availabilities", "professionals"
  add_foreign_key "professional_contracts", "job_roles"
  add_foreign_key "professional_contracts", "professionals"
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
