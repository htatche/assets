class AddRouteToMenus < ActiveRecord::Migration
  def change
    add_column :menus, :route, :string
  end
end
