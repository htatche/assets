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

ActiveRecord::Schema.define(:version => 20121217111638) do

  create_table "braindets", :force => true do |t|
    t.integer  "brdlin"
    t.string   "brdcon"
    t.string   "brddes"
    t.integer  "brdpde"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brakey"
  end

  create_table "brains", :force => true do |t|
    t.integer  "brakey"
    t.string   "bracon"
    t.string   "braori"
    t.integer  "brapor"
    t.string   "brades"
    t.integer  "brapde"
    t.string   "braimp"
    t.integer  "braipr"
    t.string   "brapag"
    t.integer  "braipa"
    t.string   "brareb"
    t.integer  "braire"
    t.string   "braini"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comptes", :force => true do |t|
    t.integer  "ctemp"
    t.integer  "ctkey"
    t.string   "ctcte"
    t.string   "ctdesc"
    t.string   "ctdesa"
    t.string   "ctindi"
    t.integer  "pgc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "empresas", :force => true do |t|
    t.integer  "empkey"
    t.string   "empnom"
    t.integer  "emppgc"
    t.integer  "emploc"
    t.integer  "emplos"
    t.string   "empdlo"
    t.string   "empdli"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histgens", :force => true do |t|
    t.integer  "hislin"
    t.integer  "ctkey"
    t.float    "import"
    t.string   "comen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hiskey"
    t.integer  "historial_id"
  end

  create_table "histimps", :force => true do |t|
    t.integer  "hislin"
    t.integer  "ctkey"
    t.float    "impbas"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "historial_id"
  end

  create_table "historials", :force => true do |t|
    t.integer  "empkey"
    t.integer  "brakey"
    t.integer  "ctkey"
    t.string   "numdoc"
    t.date     "datdoc"
    t.date     "datsis"
    t.float    "impdoc"
    t.string   "comdoc"
    t.integer  "optgen"
    t.integer  "optimp"
    t.integer  "optpag"
    t.integer  "optreb"
    t.integer  "indcom"
    t.date     "datcom"
    t.integer  "ctasse"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histpags", :force => true do |t|
    t.integer  "hislin"
    t.integer  "fpkey"
    t.float    "import"
    t.date     "datven"
    t.string   "comen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "historial_id"
  end

  create_table "menudets", :force => true do |t|
    t.integer  "mnukey"
    t.integer  "opcord"
    t.string   "opcdes"
    t.string   "opcdbo"
    t.string   "opcfrm"
    t.integer  "opcind"
    t.integer  "opcbot"
    t.integer  "brakey"
    t.integer  "pantip"
    t.integer  "mnusec"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menulits", :force => true do |t|
    t.integer  "opckey"
    t.string   "lit1"
    t.string   "lit2"
    t.string   "lit3"
    t.string   "lit4"
    t.string   "lit5"
    t.string   "lit6"
    t.string   "lit7"
    t.string   "lit8"
    t.string   "lit9"
    t.string   "lit10"
    t.string   "lit11"
    t.string   "lit12"
    t.string   "lit13"
    t.string   "lit14"
    t.string   "lit15"
    t.string   "lit16"
    t.string   "lit17"
    t.string   "lit18"
    t.string   "lit19"
    t.string   "lit20"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.integer  "mnuord"
    t.string   "mnutit"
    t.string   "mnuico"
    t.integer  "mnugrp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "route"
  end

  create_table "moviments", :force => true do |t|
    t.integer  "ctkey"
    t.string   "ctdsis"
    t.string   "ctdcta"
    t.integer  "ctclau"
    t.integer  "ctpref"
    t.integer  "ctasse"
    t.integer  "numass"
    t.string   "cttext"
    t.integer  "ctimp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pgcs", :id => false, :force => true do |t|
    t.integer  "pgccla"
    t.integer  "id"
    t.integer  "parent_id"
    t.string   "pgccte"
    t.string   "pgcdes"
    t.string   "pgcind"
    t.integer  "pgcbas"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "pgcs", ["ancestry"], :name => "index_pgcs_on_ancestry"

end
