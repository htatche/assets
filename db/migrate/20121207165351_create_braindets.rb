class CreateBraindets < ActiveRecord::Migration
  def change
    create_table :braindets do |t|
      t.integer :id
      t.integer :brdlin
      t.string :brdcon
      t.string :brddes
      t.integer :brdpde

      t.timestamps
    end
  end
end
