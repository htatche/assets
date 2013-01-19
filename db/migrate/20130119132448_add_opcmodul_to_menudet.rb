class AddOpcmodulToMenudet < ActiveRecord::Migration
  def change
    add_column :menudets, :opcmodul, :string
  end
end
