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

ActiveRecord::Schema.define(version: 20180415132140) do

  create_table "kuchikomis", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "kozure_ok",            limit: 1
    t.integer  "nyuji_ok",             limit: 1
    t.integer  "smoking",              limit: 1
    t.integer  "familymuke",           limit: 1
    t.integer  "nigiyaka",             limit: 1
    t.integer  "kids_chair",           limit: 1
    t.integer  "kids_menu",            limit: 1
    t.integer  "kids_syokki",          limit: 1
    t.integer  "low_allergy_food",     limit: 1
    t.integer  "motikomi",             limit: 1
    t.integer  "zasiki",               limit: 1
    t.integer  "kositu",               limit: 1
    t.integer  "junyusitu",            limit: 1
    t.integer  "omutu_space",          limit: 1
    t.integer  "kids_space",           limit: 1
    t.integer  "babycar",              limit: 1
    t.integer  "hirosa",               limit: 1
    t.integer  "seki_hiroi",           limit: 1
    t.integer  "suiteru",              limit: 1
    t.integer  "chusyajo",             limit: 1
    t.integer  "ekitika",              limit: 1
    t.integer  "access",               limit: 1
    t.integer  "kangei",               limit: 1
    t.integer  "kositu_zasiki_yoyaku", limit: 1
    t.integer  "ehon_omocha",          limit: 1
    t.integer  "epuron",               limit: 1
    t.integer  "eisei",                limit: 1
    t.string   "comment"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["shop_id"], name: "index_kuchikomis_on_shop_id", using: :btree
  end

  create_table "shop_photos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_shop_photos_on_shop_id", using: :btree
  end

  create_table "shops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "y_id"
    t.string   "y_gid"
    t.string   "y_uid"
    t.string   "y_ido"
    t.string   "y_keido"
    t.string   "y_address"
    t.string   "y_leadimage"
    t.boolean  "close_flg",   default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "osusume",     default: false, null: false
    t.string   "y_moyorieki"
    t.string   "y_gyosyu"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nickname"
    t.string   "email"
    t.string   "password_digest"
    t.string   "image"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "intro"
    t.integer  "age",             limit: 1
    t.string   "sex"
    t.string   "live"
  end

  add_foreign_key "kuchikomis", "shops"
  add_foreign_key "shop_photos", "shops"
end
