class Moviment < ActiveRecord::Base
  belongs_to :compte

  validates :ctkey,
    :presence => true
  validates :ctdsis,
    :presence => true
  validates :ctdcta,
    :presence => true

  validate do |f|
    errors.add(:base, 'No es una data') unless f.ctdcta.to_s.date?
  end

  validate do |f|
    errors.add(:base, 'No es una data') unless f.ctdsis.to_s.date?
  end

  validates :ctpref,
    :presence => true

  validate do |f|
    if f.ctpref != 1 && f.ctpref != -1
      errors.add(:base, 'El signe te que ser -1 o 1') 
    end
  end

  validates :ctasse,
    :presence => true

  validates :ctimp,
    :presence => true

  validates :ctimp,
    :numericality => true,
    :if => :ctimp

  after_initialize :fire
  attr_accessor :haver, :deure, :descrCompte

  def descrCompte
    self.compte.ctdesc
  end

  def self.getNewNumass
    max = maximum('numass')

    max.nil? ? 0 : max + 1
  end

  def fire
    unless self.ctimp.nil? or self.ctpref.nil? then
      if (self.ctimp * self.ctpref) < 0 then
        write_attribute(:deure_, self.ctimp)
      else
        write_attribute(:haver_, self.ctimp)
      end
    end
  end

  def haver=(import)
    unless import.empty? then
      self.ctimp = import
      self.ctpref = 1
    end
  end

  def deure=(import)
    unless import.empty? then
      self.ctimp = import
      self.ctpref = -1
    end
  end

  def set_num_compte=(numCompte)
    self.ctkey = numCompte
  end

end
