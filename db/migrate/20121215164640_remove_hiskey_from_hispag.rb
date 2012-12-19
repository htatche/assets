class RemoveHiskeyFromHispag < ActiveRecord::Migration
  def change
    remove_column :histpags, :hiskey
    add_column :histpags, :historial_id, :integer
  end
end
