class AddAncestryToPgcs < ActiveRecord::Migration
  def change
    add_column :pgcs, :ancestry, :string
    add_index :pgcs, :ancestry
  end
end
