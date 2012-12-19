class CreateBrains < ActiveRecord::Migration
  def change
    create_table :brains do |t|
      t.integer :brakey
      t.string :bracon
      t.string :braori
      t.integer :brapor
      t.string :brades
      t.integer :brapde
      t.string :braimp
      t.integer :braipr
      t.string :brapag
      t.integer :braipa
      t.string :brareb
      t.integer :braire
      t.string :braini

      t.timestamps
    end
  end
end
