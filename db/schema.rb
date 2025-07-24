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

ActiveRecord::Schema[8.0].define(version: 2025_07_24_050714) do
  create_table "payments", force: :cascade do |t|
    t.integer "topic_id"
    t.string "payment_hash"
    t.integer "amount"
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_payments_on_topic_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.integer "socratic_seminar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["socratic_seminar_id"], name: "index_sections_on_socratic_seminar_id"
  end

  create_table "socratic_seminars", force: :cascade do |t|
    t.integer "seminar_number"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "builder_sf_link"
    t.index ["seminar_number"], name: "index_socratic_seminars_on_seminar_number", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.string "lnurl"
    t.integer "sats_received", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "votes"
    t.string "link"
    t.integer "socratic_seminar_id", null: false
    t.integer "section_id", null: false
    t.index ["id"], name: "index_topics_on_id", unique: true
    t.index ["section_id"], name: "index_topics_on_section_id"
    t.index ["socratic_seminar_id"], name: "index_topics_on_socratic_seminar_id"
  end

  add_foreign_key "payments", "topics"
  add_foreign_key "sections", "socratic_seminars"
  add_foreign_key "topics", "sections"
  add_foreign_key "topics", "socratic_seminars"
end
