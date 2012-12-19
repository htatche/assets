class RemoveCtempFromMoviment < ActiveRecord::Migration
  def change
    remove_column :moviments, :ctemp
  end
end
