class RemoveMonkeyFromMoviment < ActiveRecord::Migration
  def change
    remove_column :moviments, :monkey
  end
end
