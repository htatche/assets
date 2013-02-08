class ChangeEmpresaFields < ActiveRecord::Migration
  def up
    rename_column :empresas, :database_name, :schema
    remove_column :empresas, :empkey
    add_column :empresas, :activada, :boolean
    add_column :empresas, :expiracio_contracte, :datetime
  end

  def down
  end
end
