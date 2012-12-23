class CrearUsersEmpresasJoinTable < ActiveRecord::Migration
  def up
    create_table :usuaris_empresas, :id => false do |t|
     t.integer :user_id
     t.integer :empresa_id
    end
  end

  def down
    drop_table :usuaris_empreses
  end
end
