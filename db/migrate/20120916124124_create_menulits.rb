class CreateMenulits < ActiveRecord::Migration
  def change
    create_table :menulits do |t|
      t.integer :opckey
      t.string :lit1
      t.string :lit2
      t.string :lit3
      t.string :lit4
      t.string :lit5
      t.string :lit6
      t.string :lit7
      t.string :lit8
      t.string :lit9
      t.string :lit10
      t.string :lit11
      t.string :lit12
      t.string :lit13
      t.string :lit14
      t.string :lit15
      t.string :lit16
      t.string :lit17
      t.string :lit18
      t.string :lit19
      t.string :lit20
      t.timestamps
    end
  end
end
