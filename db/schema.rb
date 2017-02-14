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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170214093427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "admin_events", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "trash",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "age_ranges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "sort_index"
    t.string   "start",      limit: 255
    t.string   "end",        limit: 255
    t.boolean  "active",                 default: false
  end

  create_table "age_ranges_profiles", force: :cascade do |t|
    t.integer "age_range_id"
    t.integer "profile_id"
  end

  add_index "age_ranges_profiles", ["profile_id"], name: "index_age_ranges_profiles_on_profile_id", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "type",                    limit: 255
    t.integer  "position"
    t.integer  "icon"
    t.string   "headline",                limit: 255
    t.text     "body"
    t.string   "button_text",             limit: 255
    t.string   "button_url",              limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "active",                              default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "search_result_position"
    t.string   "search_result_link_text", limit: 255
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_predefined",                default: false
    t.boolean  "trash",                        default: false
    t.integer  "display_order"
    t.integer  "home_page_column"
    t.integer  "see_all_column",               default: 1
  end

  create_table "categories_category_lists", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "category_list_id"
  end

  add_index "categories_category_lists", ["category_id"], name: "index_categories_category_lists_on_category_id", using: :btree
  add_index "categories_category_lists", ["category_list_id"], name: "index_categories_category_lists_on_category_list_id", using: :btree

  create_table "categories_profiles", force: :cascade do |t|
    t.integer "category_id"
    t.integer "profile_id"
  end

  add_index "categories_profiles", ["profile_id"], name: "index_categories_profiles_on_profile_id", using: :btree

  create_table "categories_services", force: :cascade do |t|
    t.integer "category_id"
    t.integer "service_id"
  end

  add_index "categories_services", ["category_id"], name: "index_categories_services_on_category_id", using: :btree
  add_index "categories_services", ["service_id"], name: "index_categories_services_on_service_id", using: :btree

  create_table "categories_subcategories", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.integer  "subcategory_display_order"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "categories_subcategories", ["category_id"], name: "index_categories_subcategories_on_category_id", using: :btree
  add_index "categories_subcategories", ["subcategory_id"], name: "index_categories_subcategories_on_subcategory_id", using: :btree

  create_table "category_lists", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "contact_blockers", force: :cascade do |t|
    t.string   "email",             limit: 255
    t.integer  "email_delivery_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "contact_blockers", ["email_delivery_id"], name: "index_contact_blockers_on_email_delivery_id", using: :btree

  create_table "customer_files", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "user_id"
    t.integer  "authorized_amount"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "stripe_card_id"
    t.boolean  "authorized",        default: true
  end

  add_index "customer_files", ["customer_id"], name: "index_customer_files_on_customer_id", using: :btree
  add_index "customer_files", ["stripe_card_id"], name: "index_customer_files_on_stripe_card_id", using: :btree
  add_index "customer_files", ["user_id"], name: "index_customer_files_on_user_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_deliveries", force: :cascade do |t|
    t.string   "recipient",         limit: 255
    t.string   "sender",            limit: 255
    t.string   "email_type",        limit: 255
    t.string   "token",             limit: 255
    t.string   "tracking_category", limit: 255
    t.integer  "profile_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "email_deliveries", ["profile_id"], name: "index_email_deliveries_on_profile_id", using: :btree
  add_index "email_deliveries", ["token"], name: "index_email_deliveries_on_token", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "address1",           limit: 255
    t.string   "address2",           limit: 255
    t.string   "city",               limit: 255
    t.string   "region",             limit: 255
    t.string   "country",            limit: 255
    t.string   "postal_code",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "search_area_tag_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "phone",              limit: 255
    t.string   "note",               limit: 255
  end

  add_index "locations", ["profile_id"], name: "index_locations_on_profile_id", using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.string   "cid",         limit: 255
    t.string   "list_id",     limit: 255
    t.string   "title",       limit: 255
    t.string   "subject",     limit: 255
    t.string   "archive_url", limit: 255
    t.text     "content"
    t.date     "send_time"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "profile_claims", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "claimant_id"
    t.string   "claimant_email", limit: 255
    t.string   "claimant_phone", limit: 255
    t.text     "admin_notes"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "first_name",                     limit: 255
    t.string   "last_name",                      limit: 255
    t.string   "middle_name",                    limit: 255
    t.string   "company_name",                   limit: 255
    t.string   "url",                            limit: 255
    t.string   "secondary_phone",                limit: 255
    t.string   "primary_phone",                  limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "user_id"
    t.string   "credentials",                    limit: 255
    t.string   "headline",                       limit: 255
    t.text     "education"
    t.text     "experience"
    t.string   "certifications",                 limit: 255
    t.text     "awards"
    t.string   "languages",                      limit: 255, default: "English"
    t.text     "summary"
    t.string   "email",                          limit: 255
    t.boolean  "consult_by_email"
    t.boolean  "consult_by_phone"
    t.boolean  "consult_by_video"
    t.boolean  "visit_home"
    t.boolean  "visit_school"
    t.text     "insurance_accepted"
    t.text     "pricing"
    t.text     "availability"
    t.boolean  "is_published",                               default: false
    t.text     "hours"
    t.text     "phone_hours"
    t.text     "video_hours"
    t.boolean  "accepting_new_clients",                      default: true
    t.boolean  "consult_in_person"
    t.string   "specialties_description",        limit: 255
    t.string   "invitation_email",               limit: 255
    t.string   "invitation_token",               limit: 255
    t.datetime "invitation_sent_at"
    t.text     "admin_notes"
    t.string   "lead_generator",                 limit: 255
    t.float    "rating_average_score"
    t.boolean  "consult_in_group"
    t.text     "service_area"
    t.boolean  "consult_at_hospital"
    t.boolean  "consult_at_camp"
    t.boolean  "consult_at_other"
    t.string   "photo_source_url",               limit: 255
    t.boolean  "trash",                                      default: false
    t.boolean  "adoption_stage"
    t.boolean  "preconception_stage"
    t.boolean  "pregnancy_stage"
    t.string   "ages",                           limit: 255
    t.string   "year_started",                   limit: 255
    t.boolean  "consult_remotely"
    t.string   "profile_photo_file_name",        limit: 255
    t.string   "profile_photo_content_type",     limit: 255
    t.integer  "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.text     "availability_service_area_note"
    t.text     "ages_stages_note"
    t.boolean  "evening_hours_available",                    default: false
    t.boolean  "weekend_hours_available",                    default: false
    t.boolean  "free_initial_consult",                       default: false
    t.boolean  "sliding_scale_available",                    default: false
    t.boolean  "financial_aid_available",                    default: false
    t.integer  "locations_count",                            default: 0,         null: false
    t.integer  "ratings_count",                              default: 0,         null: false
    t.integer  "reviews_count",                              default: 0,         null: false
    t.boolean  "public_on_private_site",                     default: false
    t.text     "widget_code"
    t.string   "invitation_tracking_category",   limit: 255
    t.text     "search_terms"
    t.text     "search_widget_code"
    t.boolean  "show_stripe_connect",                        default: true
    t.boolean  "allow_charge_authorizations",                default: true
    t.integer  "announcements_count",                        default: 0,         null: false
    t.text     "resources"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "profiles_services", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "service_id"
  end

  add_index "profiles_services", ["profile_id"], name: "index_profiles_services_on_profile_id", using: :btree

  create_table "profiles_specialties", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "specialty_id"
  end

  add_index "profiles_specialties", ["profile_id"], name: "index_profiles_specialties_on_profile_id", using: :btree

  create_table "profiles_subcategories", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "subcategory_id"
  end

  add_index "profiles_subcategories", ["profile_id"], name: "index_profiles_subcategories_on_profile_id", using: :btree
  add_index "profiles_subcategories", ["subcategory_id"], name: "index_profiles_subcategories_on_subcategory_id", using: :btree

  create_table "provider_suggestions", force: :cascade do |t|
    t.integer  "suggester_id"
    t.string   "suggester_name",                limit: 255
    t.string   "suggester_email",               limit: 255
    t.string   "provider_name",                 limit: 255
    t.string   "provider_url",                  limit: 255
    t.text     "description"
    t.text     "admin_notes"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "permission_use_suggester_name",             default: false
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "review_id"
    t.integer  "score",                     null: false
  end

  add_index "ratings", ["rateable_id", "rateable_type"], name: "index_ratings_on_rateable_id_and_rateable_type", using: :btree
  add_index "ratings", ["rater_id"], name: "index_ratings_on_rater_id", using: :btree
  add_index "ratings", ["review_id"], name: "index_ratings_on_review_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "profile_id"
    t.text     "body"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "reviewer_id"
    t.string   "title",        limit: 255
    t.text     "good_to_know"
  end

  add_index "reviews", ["profile_id"], name: "index_reviews_on_profile_id", using: :btree
  add_index "reviews", ["reviewer_id"], name: "index_reviews_on_reviewer_id", using: :btree

  create_table "search_area_tags", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "display_order"
  end

  create_table "search_terms", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "trash",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "search_terms_specialties", force: :cascade do |t|
    t.integer "search_term_id"
    t.integer "specialty_id"
  end

  add_index "search_terms_specialties", ["search_term_id"], name: "index_search_terms_specialties_on_search_term_id", using: :btree
  add_index "search_terms_specialties", ["specialty_id"], name: "index_search_terms_specialties_on_specialty_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.boolean  "is_predefined",                 default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "trash",                         default: false
    t.integer  "display_order"
    t.boolean  "show_on_home_page"
  end

  create_table "services_specialties", force: :cascade do |t|
    t.integer "service_id"
    t.integer "specialty_id"
  end

  add_index "services_specialties", ["service_id"], name: "index_services_specialties_on_service_id", using: :btree
  add_index "services_specialties", ["specialty_id"], name: "index_services_specialties_on_specialty_id", using: :btree

  create_table "services_subcategories", force: :cascade do |t|
    t.integer  "service_id"
    t.integer  "subcategory_id"
    t.integer  "service_display_order"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "services_subcategories", ["service_id"], name: "index_services_subcategories_on_service_id", using: :btree
  add_index "services_subcategories", ["subcategory_id"], name: "index_services_subcategories_on_subcategory_id", using: :btree

  create_table "specialties", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_predefined",             default: false
    t.boolean  "trash",                     default: false
  end

  create_table "story_teasers", force: :cascade do |t|
    t.boolean  "active"
    t.integer  "display_order"
    t.string   "url",           limit: 255
    t.string   "image_file",    limit: 255
    t.string   "title",         limit: 255
    t.string   "css_class",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "story_teasers", ["active", "display_order"], name: "index_story_teasers_on_active_and_display_order", using: :btree

  create_table "stripe_cards", force: :cascade do |t|
    t.integer  "stripe_customer_id"
    t.string   "api_card_id",        limit: 255
    t.boolean  "deleted",                        default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "livemode"
    t.string   "brand",              limit: 255
    t.string   "funding",            limit: 255
    t.integer  "exp_month"
    t.integer  "exp_year"
    t.string   "last4",              limit: 255
  end

  add_index "stripe_cards", ["stripe_customer_id"], name: "index_stripe_cards_on_stripe_customer_id", using: :btree

  create_table "stripe_charges", force: :cascade do |t|
    t.integer  "stripe_card_id"
    t.string   "api_charge_id",            limit: 255
    t.integer  "amount"
    t.integer  "amount_refunded"
    t.boolean  "paid",                                 default: false
    t.boolean  "refunded",                             default: false
    t.boolean  "captured",                             default: false
    t.boolean  "deleted",                              default: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "livemode"
    t.integer  "customer_file_id"
    t.string   "balance_transaction",      limit: 255
    t.integer  "fee"
    t.integer  "stripe_fee"
    t.integer  "application_fee"
    t.string   "description",              limit: 255
    t.string   "statement_description",    limit: 255
    t.integer  "fee_refunded"
    t.integer  "stripe_fee_refunded"
    t.integer  "application_fee_refunded"
    t.datetime "last_refunded_at"
  end

  add_index "stripe_charges", ["customer_file_id"], name: "index_stripe_charges_on_customer_file_id", using: :btree
  add_index "stripe_charges", ["stripe_card_id"], name: "index_stripe_charges_on_stripe_card_id", using: :btree

  create_table "stripe_customers", force: :cascade do |t|
    t.integer  "stripe_info_id"
    t.string   "api_customer_id", limit: 255
    t.string   "description",     limit: 255
    t.boolean  "deleted",                     default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "livemode"
    t.integer  "customer_id"
  end

  add_index "stripe_customers", ["customer_id"], name: "index_stripe_customers_on_customer_id", using: :btree
  add_index "stripe_customers", ["stripe_info_id"], name: "index_stripe_customers_on_stripe_info_id", using: :btree

  create_table "stripe_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_user_id",  limit: 255
    t.text     "access_token"
    t.text     "publishable_key"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "stripe_infos", ["user_id"], name: "index_stripe_infos_on_user_id", using: :btree

  create_table "subcategories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "trash",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "subscription_deliveries", force: :cascade do |t|
    t.integer  "subscription_id"
    t.integer  "subscription_stage_id"
    t.string   "email"
    t.string   "source_campaign_id"
    t.string   "campaign_id"
    t.datetime "send_time"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "subscription_deliveries", ["subscription_id"], name: "index_subscription_deliveries_on_subscription_id", using: :btree
  add_index "subscription_deliveries", ["subscription_stage_id"], name: "index_subscription_deliveries_on_subscription_stage_id", using: :btree

  create_table "subscription_stages", force: :cascade do |t|
    t.string   "title"
    t.string   "source_campaign_id"
    t.integer  "trigger_delay_days"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "list_id"
  end

  add_index "subscription_stages", ["list_id"], name: "index_subscription_stages_on_list_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.boolean  "subscribed"
    t.string   "status"
    t.string   "list_id"
    t.string   "subscriber_hash"
    t.string   "unique_email_id"
    t.string   "email"
    t.string   "fname"
    t.string   "lname"
    t.date     "birth1"
    t.date     "birth2"
    t.date     "birth3"
    t.date     "birth4"
    t.string   "zip_code"
    t.string   "postal_code"
    t.string   "country"
    t.string   "subsource"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "subscriptions", ["list_id"], name: "index_subscriptions_on_list_id", using: :btree
  add_index "subscriptions", ["subscribed"], name: "index_subscriptions_on_subscribed", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                          limit: 255, default: "",    null: false
    t.string   "encrypted_password",             limit: 255, default: "",    null: false
    t.string   "reset_password_token",           limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                              default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",             limit: 255
    t.string   "last_sign_in_ip",                limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.text     "roles"
    t.string   "phone",                          limit: 255
    t.integer  "failed_attempts",                            default: 0
    t.string   "unlock_token",                   limit: 255
    t.datetime "locked_at"
    t.string   "username",                       limit: 255
    t.string   "confirmation_token",             limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",              limit: 255
    t.datetime "welcome_sent_at"
    t.integer  "reviews_given_count",                        default: 0,     null: false
    t.datetime "admin_confirmation_sent_at"
    t.integer  "admin_confirmation_sent_by_id"
    t.string   "registration_special_code",      limit: 255
    t.boolean  "parent_marketing_emails",                    default: false
    t.boolean  "parent_newsletters",                         default: false
    t.boolean  "provider_marketing_emails",                  default: false
    t.boolean  "provider_newsletters",                       default: false
    t.boolean  "profile_help",                               default: true
    t.boolean  "signed_up_from_blog",                        default: false
    t.string   "postal_code",                    limit: 255
    t.string   "parent_marketing_emails_leid",   limit: 255
    t.string   "parent_newsletters_leid",        limit: 255
    t.string   "provider_marketing_emails_leid", limit: 255
    t.string   "provider_newsletters_leid",      limit: 255
    t.boolean  "signed_up_for_mailing_lists",                default: false
    t.string   "parent_newsletters_stage1_leid", limit: 255
    t.boolean  "parent_newsletters_stage1",                  default: false
    t.string   "parent_newsletters_stage2_leid", limit: 255
    t.boolean  "parent_newsletters_stage2",                  default: false
    t.string   "parent_newsletters_stage3_leid", limit: 255
    t.boolean  "parent_newsletters_stage3",                  default: false
    t.integer  "second_factor_attempts_count",               default: 0
    t.string   "encrypted_otp_secret_key",       limit: 255
    t.string   "encrypted_otp_secret_key_iv",    limit: 255
    t.string   "encrypted_otp_secret_key_salt",  limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["encrypted_otp_secret_key"], name: "index_users_on_encrypted_otp_secret_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "subscription_deliveries", "subscription_stages"
  add_foreign_key "subscription_deliveries", "subscriptions"
end
