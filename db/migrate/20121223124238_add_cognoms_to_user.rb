class AddCognomsToUser < ActiveRecord::Migration
  def change
    add_column :users, :cognoms, :string
  end
end
