class CreateComptes < ActiveRecord::Migration
  def change
    create_table :comptes do |t|
      t.integer :ctemp
      t.integer :ctkey
      t.string :ctcte
      t.string :ctdesc
      t.string :ctdesa
      t.string :ctindi
      t.integer :pgckey

      t.timestamps
    end
  end
end
