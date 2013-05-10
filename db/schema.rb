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

ActiveRecord::Schema.define(:version => 20130510211358) do

  create_table "age_ranges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "sort_index"
    t.string   "start"
    t.string   "end"
  end

  create_table "age_ranges_profiles", :force => true do |t|
    t.integer "age_range_id"
    t.integer "profile_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_predefined", :default => false
  end

  create_table "categories_profiles", :force => true do |t|
    t.integer "category_id"
    t.integer "profile_id"
  end

  create_table "categories_services", :force => true do |t|
    t.integer "category_id"
    t.integer "service_id"
  end

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
  end

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "company_name"
    t.string   "url"
    t.string   "secondary_phone"
    t.string   "primary_phone"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "user_id"
    t.string   "credentials"
    t.string   "headline"
    t.text     "education"
    t.text     "experience"
    t.string   "certifications"
    t.text     "awards"
    t.string   "languages"
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
    t.boolean  "is_published",            :default => false
    t.text     "hours"
    t.text     "phone_hours"
    t.text     "video_hours"
    t.boolean  "accepting_new_clients",   :default => true
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
  end

  create_table "profiles_services", :force => true do |t|
    t.integer "profile_id"
    t.integer "service_id"
  end

  create_table "profiles_specialties", :force => true do |t|
    t.integer "profile_id"
    t.integer "specialty_id"
  end

  create_table "ratings", :force => true do |t|
    t.float    "score",         :null => false
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "search_area_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "display_order"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.boolean  "is_predefined", :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "services_specialties", :force => true do |t|
    t.integer "service_id"
    t.integer "specialty_id"
  end

  create_table "specialties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_predefined", :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "roles"
    t.string   "phone"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "username"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
