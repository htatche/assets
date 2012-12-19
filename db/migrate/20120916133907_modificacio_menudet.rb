class ModificacioMenudet < ActiveRecord::Migration
  def change
    change_table :menudets do |t|
      t.rename :opccord, :opcord
    end
  end
end
