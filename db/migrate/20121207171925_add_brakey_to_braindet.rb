class AddBrakeyToBraindet < ActiveRecord::Migration
  def change
    add_column :braindets, :brakey, :integer
  end
end
