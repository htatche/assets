class MakeChangesToPgc < ActiveRecord::Migration
  def change
    rename_column :pgcs, :pgckpa, :parent_id
    remove_column :pgcs, :id2
    rename_column :pgcs, :pgckey, :id
  end

  def down
  end
end
