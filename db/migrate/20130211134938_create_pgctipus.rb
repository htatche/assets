class CreatePgctipus < ActiveRecord::Migration
  def change
    create_table :pgctipus do |t|
      t.string :descripcio

      t.timestamps
    end
  end
end
