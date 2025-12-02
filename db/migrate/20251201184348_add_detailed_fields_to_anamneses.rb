# frozen_string_literal: true

class AddDetailedFieldsToAnamneses < ActiveRecord::Migration[8.0]
  def change
    change_table :anamneses, bulk: true do |t|
      t.time :start_time
      t.string :session_email
      t.string :birthplace
      t.string :birth_state
      t.string :religion

      t.string :father_cpf
      t.string :father_workplace
      t.string :mother_cpf
      t.string :mother_workplace
      t.json :family_composition

      t.text :main_complaint
      t.text :complaint_noticed_since

      t.boolean :pregnancy_planned
      t.boolean :prenatal_care
      t.integer :mother_age_at_birth
      t.boolean :had_miscarriages
      t.integer :miscarriages_count
      t.string :miscarriages_type
      t.boolean :pregnancy_trauma
      t.boolean :pregnancy_illness
      t.string :pregnancy_illness_description
      t.boolean :pregnancy_medication
      t.string :pregnancy_medication_description
      t.boolean :pregnancy_drugs
      t.string :pregnancy_drugs_description
      t.boolean :pregnancy_alcohol
      t.boolean :pregnancy_smoking
      t.integer :cigarettes_per_day

      t.string :birth_type
      t.string :birth_location_type
      t.string :birth_term
      t.boolean :had_anesthesia
      t.string :anesthesia_type
      t.string :baby_position
      t.boolean :cried_at_birth
      t.integer :apgar_1min
      t.integer :apgar_5min
      t.integer :mother_hospital_days
      t.integer :baby_hospital_days
      t.decimal :birth_weight, precision: 5, scale: 3
      t.decimal :birth_height, precision: 5, scale: 2
      t.boolean :needed_incubator
      t.boolean :needed_icu
      t.text :icu_reason
      t.text :birth_complications

      t.text :baby_health
      t.text :respiratory_problems
      t.text :general_behavior_baby

      t.boolean :breastfed
      t.string :breastfed_until
      t.boolean :bottle_fed
      t.string :bottle_fed_until
      t.text :feeding_contact
      t.boolean :daily_meals
      t.text :favorite_foods
      t.text :rejected_foods
      t.boolean :frequent_vomiting
      t.text :meal_behavior
      t.boolean :fixed_meal_schedule
      t.boolean :eats_alone
      t.boolean :chewing_difficulty
      t.boolean :drools
      t.string :drools_when
      t.text :feeding_notes

      t.boolean :held_head
      t.string :held_head_age
      t.boolean :rolled_over
      t.boolean :rolled_bilateral
      t.text :rolled_notes
      t.boolean :sat_unsupported
      t.string :sat_unsupported_age
      t.boolean :crawled
      t.string :crawled_age
      t.text :crawled_how
      t.string :stood_age
      t.string :walked_age
      t.boolean :climbed_stairs
      t.string :climbed_stairs_age
      t.boolean :squatted
      t.string :squatted_age
      t.boolean :used_walker
      t.string :used_walker_age
      t.boolean :motor_coordination_problem
      t.text :motor_coordination_description
      t.boolean :object_manipulation_difficulty

      t.string :bladder_control_day
      t.string :bladder_control_night
      t.string :bowel_control_day
      t.string :bowel_control_night

      t.boolean :babbled
      t.string :babbled_age
      t.string :speech_started_age
      t.boolean :understandable_speech
      t.string :understandable_since
      t.boolean :speech_difficulties
      t.text :speech_difficulties_description
      t.boolean :echolalia
      t.boolean :hearing_problems
      t.text :hearing_problems_description
      t.boolean :responds_from_distance
      t.boolean :easily_startled
      t.boolean :uses_gestures
      t.text :gestures_description
      t.boolean :uses_other_as_tool
      t.boolean :words_in_context
      t.boolean :shares_interests
      t.boolean :stopped_speaking
      t.string :stopped_speaking_when
      t.boolean :understands_speech
      t.text :communicates_desires
      t.text :reaction_not_understood
      t.text :family_reaction_communication

      t.boolean :sleep_routine
      t.text :sleep_routine_description
      t.boolean :individual_bed
      t.text :individual_bed_description
      t.text :sleep_quality
      t.boolean :nocturnal_enuresis

      t.text :preferred_play
      t.text :how_plays
      t.text :protective_reaction_play
      t.text :favorite_toys
      t.boolean :watches_tv
      t.text :watches_tv_how
      t.text :favorite_programs
      t.boolean :watches_repeatedly
      t.boolean :plays_with_others
      t.text :plays_with_others_how
      t.text :fights_with_peers
      t.boolean :defends_from_aggression
      t.text :defense_method
      t.text :reaction_prohibitions
      t.text :behavior_with_strangers
      t.boolean :danger_awareness
      t.text :danger_awareness_description
      t.text :new_situations_reaction
      t.boolean :obeys_orders
      t.text :shows_affection
      t.boolean :aggressive_behavior
      t.text :aggressive_behavior_description
      t.text :family_crisis_reaction

      t.string :school_phone
      t.string :school_enrollment_age
      t.boolean :has_support_teacher
      t.text :after_school_activities
      t.text :school_difficulties
      t.text :family_school_expectations

      t.text :previous_illnesses
      t.boolean :hospitalizations
      t.text :hospitalization_causes
      t.boolean :has_epilepsy
      t.string :epilepsy_frequency
      t.text :current_medications
      t.text :exams_done
      t.text :exams_to_do
      t.boolean :has_allergies
      t.text :allergies_description
      t.json :family_conditions
      t.boolean :psychiatric_hospitalization
      t.string :psychiatric_hospitalization_who

      t.text :general_information
    end
  end
end
