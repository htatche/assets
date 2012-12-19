class AddHiskeyToHistgen < ActiveRecord::Migration
  def change
    add_column :histgens, :hiskey, :integer 
  end
end
