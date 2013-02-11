class EliminarEmpkeyDeHistorial < ActiveRecord::Migration
  def change
    remove_column :historials, :empkey
  end
end
