class AddDatabaseNameToEmpresa < ActiveRecord::Migration
  def change
    add_column :empresas, :database_name, :string
  end
end
