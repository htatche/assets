class Menulit < ActiveRecord::Base
  def self.getFormLabels(option)
    row = where('opckey = ?', option).first
  end
end
