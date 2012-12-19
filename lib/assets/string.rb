# coding: utf-8

class String
  def numeric?
    Float(self) != nil rescue false
  end

  def sanitizeCurrency
    self.delete('€').delete(' ').gsub(',','.')
  end
end
