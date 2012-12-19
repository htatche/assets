class CreateMoviments < ActiveRecord::Migration
  def change
    create_table :moviments do |t|
      t.integer :ctemp
      t.integer :ctkey
      t.integer :monkey
      t.string :ctdsis
      t.string :ctdcta
      t.integer :ctclau
      t.integer :ctpref
      t.integer :ctasse
      t.integer :numass
      t.string :cttext
      t.integer :ctimp

      t.timestamps
    end
  end
end
