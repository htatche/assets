class CreateHistorials < ActiveRecord::Migration
  def change
    create_table :historials do |t|
      t.integer :empkey
      t.integer :brakey
      t.integer :ctkey
      t.string :numdoc
      t.date :datdoc
      t.date :datsis
      t.float :impdoc
      t.string :comdoc
      t.integer :optgen
      t.integer :optimp
      t.integer :optpag
      t.integer :optreb
      t.integer :indcom
      t.date :datcom
      t.integer :ctasse

      t.timestamps
    end
  end
end
