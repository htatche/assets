class AddHistorialIdToHistgen < ActiveRecord::Migration
  def change
    add_column :histgens, :historial_id, :integer
  end
end
