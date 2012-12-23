class Empresa < ActiveRecord::Base
  has_and_belongs_to_many :users

  def self.cteMaxLength(empkey)
    find(empkey).emploc
  end

end
