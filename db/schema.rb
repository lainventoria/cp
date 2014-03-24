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

ActiveRecord::Schema.define(version: 20140318231717) do

  create_table "cajas", force: true do |t|
    t.integer  "obra_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo",       null: false
    t.string   "banco"
    t.string   "numero"
    t.string   "situacion"
  end

  create_table "cheques", force: true do |t|
    t.string   "situacion",         default: "propio"
    t.integer  "numero"
    t.integer  "monto_centavos",    default: 0,          null: false
    t.string   "monto_moneda",      default: "ARS",      null: false
    t.datetime "fecha_vencimiento"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fecha_emision"
    t.integer  "recibo_id"
    t.string   "beneficiario"
    t.string   "banco"
    t.integer  "caja_id"
    t.string   "estado",            default: "chequera"
    t.integer  "destino_id"
  end

  add_index "cheques", ["caja_id"], name: "index_cheques_on_caja_id"
  add_index "cheques", ["destino_id"], name: "index_cheques_on_destino_id"
  add_index "cheques", ["recibo_id"], name: "index_cheques_on_recibo_id"

  create_table "facturas", force: true do |t|
    t.string   "tipo"
    t.string   "numero"
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
    t.integer  "importe_neto_centavos",  default: 0,      null: false
    t.string   "importe_neto_moneda",    default: "ARS",  null: false
    t.integer  "iva_centavos",           default: 0,      null: false
    t.string   "iva_moneda",             default: "ARS",  null: false
    t.integer  "tercero_id"
    t.integer  "obra_id"
  end

  add_index "facturas", ["obra_id"], name: "index_facturas_on_obra_id"
  add_index "facturas", ["tercero_id"], name: "index_facturas_on_tercero_id"

  create_table "movimientos", force: true do |t|
    t.integer  "caja_id"
    t.integer  "monto_centavos", default: 0,     null: false
    t.string   "monto_moneda",   default: "ARS", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recibo_id"
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
    t.string   "cuit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relacion"
    t.string   "contacto"
    t.text     "notas"
  end

end
