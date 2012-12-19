class CreateMenudets < ActiveRecord::Migration
  def change
    create_table :menudets do |t|
      t.integer :mnukey
      t.integer :opccord
      t.string :opcdes
      t.string :opcdbo
      t.string :opcfrm
      t.integer :opcind
      t.integer :opcbot
      t.integer :brakey
      t.integer :pantip
      t.integer :mnusec

      t.timestamps
    end
  end
end
