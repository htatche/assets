class AddHiskeyToHistpag < ActiveRecord::Migration
  def change
    add_column :histpags, :hiskey, :integer
  end
end
