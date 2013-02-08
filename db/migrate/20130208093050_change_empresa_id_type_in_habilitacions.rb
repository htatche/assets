class ChangeEmpresaIdTypeInHabilitacions < ActiveRecord::Migration
  def change
    remove_column :habilitacions, :empresa_id
    add_column :habilitacions, :empresa_id, :integer
  end

  def down
  end
end
