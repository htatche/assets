class Empresa < ActiveRecord::Base

  def self.cteMaxLength(empkey)
    find(empkey).emploc
  end

end
