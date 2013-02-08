class RemoveTableUsuarisEmpresas < ActiveRecord::Migration
  def up
    drop_table :usuaris_empresas
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
