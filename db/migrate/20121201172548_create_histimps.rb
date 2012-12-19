class CreateHistimps < ActiveRecord::Migration
  def change
    create_table :histimps do |t|
      t.integer :hislin
      t.integer :ctkey
      t.float :impbas

      t.timestamps
    end
  end
end
