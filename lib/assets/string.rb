# coding: utf-8

class String
  def numeric?
    Float(self) != nil rescue false
  end

  def date?
    self.is_a?(Date)
  end

  def sanitizeCurrency
    self.delete('€').delete(' ').gsub(',','.')
  end
end
