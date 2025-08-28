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

ActiveRecord::Schema[8.0].define(version: 2025_08_28_192359) do
  create_table "organization_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_roles_on_organization_id"
    t.index ["user_id", "organization_id", "role"], name: "index_org_roles_on_user_org_and_role", unique: true
    t.index ["user_id"], name: "index_organization_roles_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "country", limit: 2
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bolt12_invoice"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "topic_id"
    t.string "payment_hash"
    t.integer "amount"
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_payments_on_topic_id"
  end

  create_table "payouts", force: :cascade do |t|
    t.integer "socratic_seminar_id", null: false
    t.integer "organization_id", null: false
    t.integer "amount"
    t.text "invoice"
    t.string "payment_hash"
    t.string "status"
    t.text "memo"
    t.json "lnbits_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_type"
    t.index ["invoice_type"], name: "index_payouts_on_invoice_type"
    t.index ["organization_id"], name: "index_payouts_on_organization_id"
    t.index ["socratic_seminar_id"], name: "index_payouts_on_socratic_seminar_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.integer "socratic_seminar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order", default: 0, null: false
    t.boolean "allow_public_submissions", default: false
    t.index ["socratic_seminar_id", "order"], name: "index_sections_on_socratic_seminar_id_and_order"
    t.index ["socratic_seminar_id"], name: "index_sections_on_socratic_seminar_id"
  end

  create_table "site_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "role"], name: "index_site_roles_on_user_id_and_role", unique: true
    t.index ["user_id"], name: "index_site_roles_on_user_id"
  end

  create_table "socratic_seminars", force: :cascade do |t|
    t.integer "seminar_number"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "topics_list_url"
    t.integer "organization_id", null: false
    t.index ["organization_id", "seminar_number"], name: "index_socratic_seminars_on_organization_id_and_seminar_number", unique: true
    t.index ["organization_id"], name: "index_socratic_seminars_on_organization_id"
  end

  create_table "toggles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_toggles_on_name", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.string "lnurl"
    t.integer "sats_received", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "votes", default: 0, null: false
    t.string "link"
    t.integer "section_id", null: false
    t.integer "parent_topic_id"
    t.index ["id"], name: "index_topics_on_id", unique: true
    t.index ["parent_topic_id"], name: "index_topics_on_parent_topic_id"
    t.index ["section_id"], name: "index_topics_on_section_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "organization_roles", "organizations"
  add_foreign_key "organization_roles", "users"
  add_foreign_key "payments", "topics"
  add_foreign_key "payouts", "organizations"
  add_foreign_key "payouts", "socratic_seminars"
  add_foreign_key "sections", "socratic_seminars"
  add_foreign_key "site_roles", "users"
  add_foreign_key "socratic_seminars", "organizations"
  add_foreign_key "topics", "sections"
end
