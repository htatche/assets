class CreateHistpags < ActiveRecord::Migration
  def change
    create_table :histpags do |t|
      t.integer :hislin
      t.integer :fpkey
      t.float :import
      t.date :datven
      t.string :comen

      t.timestamps
    end
  end
end
