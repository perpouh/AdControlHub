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

ActiveRecord::Schema[7.2].define(version: 2025_07_20_035954) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "advertisement_analytics", force: :cascade do |t|
    t.string "advertisement_id"
    t.datetime "target_date"
    t.string "search_word"
    t.integer "click_count"
    t.datetime "archived_at"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "title", null: false
    t.string "link_url", null: false
    t.string "image_url"
    t.boolean "active", default: false
    t.string "tags", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ad_type", default: "image", null: false
    t.string "ad_size", default: "square", null: false
    t.string "alt_text"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
