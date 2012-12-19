class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer :mnuord
      t.string :mnutit
      t.string :mnuico
      t.integer :mnugrp

      t.timestamps
    end
  end
end
