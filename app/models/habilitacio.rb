class Habilitacio < ActiveRecord::Base
  set_table_name 'habilitacions'

  belongs_to :user
  belongs_to :empresa
end
