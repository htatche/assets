class CreateHabilitacios < ActiveRecord::Migration
  def change
    create_table :habilitacions do |t|
      t.integer :user_id
      t.string :empresa_id
      t.integer :level
 
      t.timestamps
    end
  end
end
