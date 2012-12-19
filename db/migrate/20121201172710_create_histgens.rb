class CreateHistgens < ActiveRecord::Migration
  def change
    create_table :histgens do |t|
      t.integer :hislin
      t.integer :ctkey
      t.float :import
      t.string :comen

      t.timestamps
    end
  end
end
