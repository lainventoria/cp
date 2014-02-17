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

ActiveRecord::Schema.define(version: 20140210222845) do

  create_table "cajas", force: true do |t|
    t.integer  "obra_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo",       default: "De obra", null: false
  end

  create_table "cuentas", force: true do |t|
    t.string   "numero"
    t.integer  "obra_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facturas", force: true do |t|
    t.string   "tipo"
    t.string   "numero"
    t.text     "nombre"
    t.text     "domicilio"
    t.text     "cuit"
    t.float    "iva"
    t.text     "descripcion"
    t.integer  "importe_total_centavos", default: 0,      null: false
    t.string   "importe_total_moneda",   default: "ARS",  null: false
    t.datetime "fecha"
    t.datetime "fecha_pago"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "situacion",              default: "pago"
    t.integer  "saldo_centavos",         default: 0,      null: false
    t.string   "saldo_moneda",           default: "ARS",  null: false
  end

  create_table "movimientos", force: true do |t|
    t.integer  "caja_id"
    t.integer  "monto_centavos", default: 0,     null: false
    t.string   "monto_moneda",   default: "ARS", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "obras", force: true do |t|
    t.string   "nombre"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "direccion"
  end

  create_table "recibos", force: true do |t|
    t.datetime "fecha"
    t.integer  "importe_centavos", default: 0,      null: false
    t.string   "importe_moneda",   default: "ARS",  null: false
    t.integer  "factura_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "situacion",        default: "pago"
  end

  add_index "recibos", ["factura_id"], name: "index_recibos_on_factura_id"

  create_table "terceros", force: true do |t|
    t.string   "nombre"
    t.text     "direccion"
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
