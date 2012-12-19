class RemoveHiskeyFromHistimp < ActiveRecord::Migration
  def change
    remove_column :histimps, :hiskey
    add_column :histimps, :historial_id, :integer
  end
end
