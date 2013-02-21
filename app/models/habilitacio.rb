class Habilitacio < ActiveRecord::Base
  self.table_name = 'habilitacions'

  belongs_to :user
  belongs_to :empresa
end
