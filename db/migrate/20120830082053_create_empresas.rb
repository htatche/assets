class CreateEmpresas < ActiveRecord::Migration
  def change
    create_table :empresas do |t|
      t.integer :empkey
      t.string :empnom
      t.integer :emppgc
      t.integer :emploc
      t.integer :emplos
      t.string :empdlo
      t.string :empdli

      t.timestamps
    end
  end
end
