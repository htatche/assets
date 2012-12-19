class RenamePgckeyFromComptesToPgcId < ActiveRecord::Migration
  def change
    rename_column :comptes, :pgckey, :pgc_id
  end

  def up
  end

  def down
  end
end
