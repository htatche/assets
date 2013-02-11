class CreateParametres < ActiveRecord::Migration
  def change
    create_table :parametres do |t|
      t.integer :pgc_id
      t.integer :long_compte
      t.integer :long_sufix

      t.timestamps
    end
  end
end
