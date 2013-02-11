# coding: utf-8

class String
  def numeric?
    Float(self) != nil rescue false
  end

  def is_a_date?
    begin
      Date.strptime("{ #{self} }", "{ %d/%m/%Y }")
    rescue
      return false
    end
    
    return true
  end

  def sanitizeCurrency
    self.delete('€').delete(' ').gsub(',','.')
  end
end
