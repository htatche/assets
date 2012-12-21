# coding: utf-8

class String
  def numeric?
    Float(self) != nil rescue false
  end

  def date?
    begin
      Date.parse(self)
    rescue
      false
    else
      true
    end
  end

  def sanitizeCurrency
    self.delete('€').delete(' ').gsub(',','.')
  end
end
