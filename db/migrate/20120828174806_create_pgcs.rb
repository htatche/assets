class CreatePgcs < ActiveRecord::Migration
  def change
    create_table :pgcs do |t|
      t.integer :pgccla
      t.integer :pgckey
      t.integer :pgckpa
      t.string :pgccte
      t.string :pgcdes
      t.string :pgcind
      t.integer :pgcbas

      t.timestamps
    end
  end
end
