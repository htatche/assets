class MakeChangesToPgc < ActiveRecord::Migration
  def change
    rename_column :pgcs, :pgckpa, :parent_id
  end

  def down
  end
end
