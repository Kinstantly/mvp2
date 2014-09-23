# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140923180023) do

  create_table "admin_events", :force => true do |t|
    t.string   "name"
    t.boolean  "trash",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "age_ranges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "sort_index"
    t.string   "start"
    t.string   "end"
    t.boolean  "active",     :default => false
  end

  create_table "age_ranges_profiles", :force => true do |t|
    t.integer "age_range_id"
    t.integer "profile_id"
  end

  add_index "age_ranges_profiles", ["profile_id"], :name => "index_age_ranges_profiles_on_profile_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_predefined",    :default => false
    t.boolean  "trash",            :default => false
    t.integer  "display_order"
    t.integer  "home_page_column"
    t.integer  "see_all_column",   :default => 1
  end

  create_table "categories_category_lists", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "category_list_id"
  end

  add_index "categories_category_lists", ["category_id"], :name => "index_categories_category_lists_on_category_id"
  add_index "categories_category_lists", ["category_list_id"], :name => "index_categories_category_lists_on_category_list_id"

  create_table "categories_profiles", :force => true do |t|
    t.integer "category_id"
    t.integer "profile_id"
  end

  add_index "categories_profiles", ["profile_id"], :name => "index_categories_profiles_on_profile_id"

  create_table "categories_services", :force => true do |t|
    t.integer "category_id"
    t.integer "service_id"
  end

  add_index "categories_services", ["category_id"], :name => "index_categories_services_on_category_id"
  add_index "categories_services", ["service_id"], :name => "index_categories_services_on_service_id"

  create_table "categories_subcategories", :force => true do |t|
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.integer  "subcategory_display_order"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "categories_subcategories", ["category_id"], :name => "index_categories_subcategories_on_category_id"
  add_index "categories_subcategories", ["subcategory_id"], :name => "index_categories_subcategories_on_subcategory_id"

  create_table "category_lists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contact_blockers", :force => true do |t|
    t.string   "email"
    t.integer  "email_delivery_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "contact_blockers", ["email_delivery_id"], :name => "index_contact_blockers_on_email_delivery_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "email_deliveries", :force => true do |t|
    t.string   "recipient"
    t.string   "sender"
    t.string   "email_type"
    t.string   "token"
    t.string   "tracking_category"
    t.integer  "profile_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "email_deliveries", ["profile_id"], :name => "index_email_deliveries_on_profile_id"
  add_index "email_deliveries", ["token"], :name => "index_email_deliveries_on_token"

  create_table "locations", :force => true do |t|
    t.integer  "profile_id"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "postal_code"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "search_area_tag_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone"
    t.string   "note"
  end

  add_index "locations", ["profile_id"], :name => "index_locations_on_profile_id"

  create_table "profile_claims", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "claimant_id"
    t.string   "claimant_email"
    t.string   "claimant_phone"
    t.text     "admin_notes"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "company_name"
    t.string   "url"
    t.string   "secondary_phone"
    t.string   "primary_phone"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "user_id"
    t.string   "credentials"
    t.string   "headline"
    t.text     "education"
    t.text     "experience"
    t.string   "certifications"
    t.text     "awards"
    t.string   "languages",                      :default => "English"
    t.text     "summary"
    t.string   "email"
    t.boolean  "consult_by_email"
    t.boolean  "consult_by_phone"
    t.boolean  "consult_by_video"
    t.boolean  "visit_home"
    t.boolean  "visit_school"
    t.text     "insurance_accepted"
    t.text     "pricing"
    t.text     "availability"
    t.boolean  "is_published",                   :default => false
    t.text     "hours"
    t.text     "phone_hours"
    t.text     "video_hours"
    t.boolean  "accepting_new_clients",          :default => true
    t.boolean  "consult_in_person"
    t.string   "specialties_description"
    t.string   "invitation_email"
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.text     "admin_notes"
    t.string   "lead_generator"
    t.float    "rating_average_score"
    t.boolean  "consult_in_group"
    t.text     "service_area"
    t.boolean  "consult_at_hospital"
    t.boolean  "consult_at_camp"
    t.boolean  "consult_at_other"
    t.string   "photo_source_url"
    t.boolean  "trash",                          :default => false
    t.boolean  "adoption_stage"
    t.boolean  "preconception_stage"
    t.boolean  "pregnancy_stage"
    t.string   "ages"
    t.string   "year_started"
    t.boolean  "consult_remotely"
    t.string   "profile_photo_file_name"
    t.string   "profile_photo_content_type"
    t.integer  "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.text     "availability_service_area_note"
    t.text     "ages_stages_note"
    t.boolean  "evening_hours_available",        :default => false
    t.boolean  "weekend_hours_available",        :default => false
    t.boolean  "free_initial_consult",           :default => false
    t.boolean  "sliding_scale_available",        :default => false
    t.boolean  "financial_aid_available",        :default => false
    t.integer  "locations_count",                :default => 0,         :null => false
    t.integer  "ratings_count",                  :default => 0,         :null => false
    t.integer  "reviews_count",                  :default => 0,         :null => false
    t.boolean  "public_on_private_site",         :default => false
    t.text     "widget_code"
    t.string   "invitation_tracking_category"
    t.text     "search_terms"
    t.text     "search_widget_code"
    t.boolean  "show_stripe_connect",            :default => false
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "profiles_services", :force => true do |t|
    t.integer "profile_id"
    t.integer "service_id"
  end

  add_index "profiles_services", ["profile_id"], :name => "index_profiles_services_on_profile_id"

  create_table "profiles_specialties", :force => true do |t|
    t.integer "profile_id"
    t.integer "specialty_id"
  end

  add_index "profiles_specialties", ["profile_id"], :name => "index_profiles_specialties_on_profile_id"

  create_table "profiles_subcategories", :force => true do |t|
    t.integer "profile_id"
    t.integer "subcategory_id"
  end

  add_index "profiles_subcategories", ["profile_id"], :name => "index_profiles_subcategories_on_profile_id"
  add_index "profiles_subcategories", ["subcategory_id"], :name => "index_profiles_subcategories_on_subcategory_id"

  create_table "provider_suggestions", :force => true do |t|
    t.integer  "suggester_id"
    t.string   "suggester_name"
    t.string   "suggester_email"
    t.string   "provider_name"
    t.string   "provider_url"
    t.text     "description"
    t.text     "admin_notes"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.boolean  "permission_use_suggester_name", :default => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "review_id"
    t.integer  "score",         :null => false
  end

  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"
  add_index "ratings", ["review_id"], :name => "index_ratings_on_review_id"

  create_table "reviews", :force => true do |t|
    t.integer  "profile_id"
    t.text     "body"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "reviewer_id"
    t.string   "title"
    t.text     "good_to_know"
  end

  add_index "reviews", ["profile_id"], :name => "index_reviews_on_profile_id"
  add_index "reviews", ["reviewer_id"], :name => "index_reviews_on_reviewer_id"

  create_table "search_area_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "display_order"
  end

  create_table "search_terms", :force => true do |t|
    t.string   "name"
    t.boolean  "trash",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "search_terms_specialties", :force => true do |t|
    t.integer "search_term_id"
    t.integer "specialty_id"
  end

  add_index "search_terms_specialties", ["search_term_id"], :name => "index_search_terms_specialties_on_search_term_id"
  add_index "search_terms_specialties", ["specialty_id"], :name => "index_search_terms_specialties_on_specialty_id"

  create_table "services", :force => true do |t|
    t.string   "name"
    t.boolean  "is_predefined",     :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "trash",             :default => false
    t.integer  "display_order"
    t.boolean  "show_on_home_page"
  end

  create_table "services_specialties", :force => true do |t|
    t.integer "service_id"
    t.integer "specialty_id"
  end

  add_index "services_specialties", ["service_id"], :name => "index_services_specialties_on_service_id"
  add_index "services_specialties", ["specialty_id"], :name => "index_services_specialties_on_specialty_id"

  create_table "services_subcategories", :force => true do |t|
    t.integer  "service_id"
    t.integer  "subcategory_id"
    t.integer  "service_display_order"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "services_subcategories", ["service_id"], :name => "index_services_subcategories_on_service_id"
  add_index "services_subcategories", ["subcategory_id"], :name => "index_services_subcategories_on_subcategory_id"

  create_table "specialties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_predefined", :default => false
    t.boolean  "trash",         :default => false
  end

  create_table "stripe_cards", :force => true do |t|
    t.integer  "stripe_customer_id"
    t.string   "api_card_id"
    t.boolean  "deleted",            :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "livemode"
  end

  add_index "stripe_cards", ["stripe_customer_id"], :name => "index_stripe_cards_on_stripe_customer_id"

  create_table "stripe_charges", :force => true do |t|
    t.integer  "stripe_card_id"
    t.string   "api_charge_id"
    t.integer  "amount"
    t.integer  "amount_refunded"
    t.boolean  "paid",            :default => false
    t.boolean  "refunded",        :default => false
    t.boolean  "captured",        :default => false
    t.boolean  "deleted",         :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "livemode"
  end

  add_index "stripe_charges", ["stripe_card_id"], :name => "index_stripe_charges_on_stripe_card_id"

  create_table "stripe_customers", :force => true do |t|
    t.integer  "stripe_info_id"
    t.string   "api_customer_id"
    t.string   "description"
    t.boolean  "deleted",         :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "livemode"
  end

  add_index "stripe_customers", ["stripe_info_id"], :name => "index_stripe_customers_on_stripe_info_id"

  create_table "stripe_infos", :force => true do |t|
    t.integer  "user_id"
    t.string   "stripe_user_id"
    t.text     "access_token"
    t.text     "publishable_key"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "stripe_infos", ["user_id"], :name => "index_stripe_infos_on_user_id"

  create_table "subcategories", :force => true do |t|
    t.string   "name"
    t.boolean  "trash",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                         :default => "",    :null => false
    t.string   "encrypted_password",            :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.text     "roles"
    t.string   "phone"
    t.integer  "failed_attempts",               :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "username"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "welcome_sent_at"
    t.integer  "reviews_given_count",           :default => 0,     :null => false
    t.datetime "admin_confirmation_sent_at"
    t.integer  "admin_confirmation_sent_by_id"
    t.string   "registration_special_code"
    t.boolean  "parent_marketing_emails",       :default => false
    t.boolean  "parent_newsletters",            :default => false
    t.boolean  "provider_marketing_emails",     :default => false
    t.boolean  "provider_newsletters",          :default => false
    t.boolean  "profile_help",                  :default => true
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
