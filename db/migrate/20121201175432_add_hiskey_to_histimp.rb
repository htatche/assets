class AddHiskeyToHistimp < ActiveRecord::Migration
  def change
    add_column :histimps, :hiskey, :integer
  end
end
