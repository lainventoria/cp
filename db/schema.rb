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

ActiveRecord::Schema.define(version: 20140117221154) do

  create_table "cajas", force: true do |t|
    t.integer  "obra_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cuentas", force: true do |t|
    t.string   "numero"
    t.integer  "obra_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "obras", force: true do |t|
    t.string   "nombre"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "terceros", force: true do |t|
    t.string   "nombre"
    t.text     "direccions"
    t.text     "telefono"
    t.text     "celular"
    t.string   "email"
    t.float    "iva"
    t.boolean  "proveedor"
    t.boolean  "cliente"
    t.string   "cuit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
