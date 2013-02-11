class EliminarCampsDeEmpresa < ActiveRecord::Migration
  def change
    remove_column :empresas, :emppgc
    remove_column :empresas, :emploc
    remove_column :empresas, :emplos
    remove_column :empresas, :empdlo
    remove_column :empresas, :empdli
  end
end
