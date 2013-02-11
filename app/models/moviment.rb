class Moviment < ActiveRecord::Base
  belongs_to :compte

  validates :ctkey,
    :presence => true
  validates :ctdsis,
    :presence => true
  validates :ctdcta,
    :presence => true

  validate :ctdcta_is_a_data?

  validates :ctpref,
    :presence => true

  validate do |f|
    if f.ctpref != 1 && f.ctpref != -1
      errors.add(:ctpref, 'El signe te que ser -1 o 1') 
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
#attr_accessor :haver, :deure

  private

  def ctdcta_is_a_data?
    errors.add(:ctdcta, :not_a_date) unless ctdcta.is_a_date?
  end

  public

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

  def self.comptabilitzar (apunts)
    clau_ass =  (Historial.maximum('id') if Historial.any?) || 1
    num_ass =  (Moviment.maximum('numass') if Moviment.any?) || 1

    apunts.each_with_index { |a, idx|
      a = a[1]
      wkey = idx
      
      signe = a['deure'] != '0' ? 1 : -1
      import = a['deure'] != '' ? a['deure'] : a['haver']

      new({
        :ctkey => Compte.find_by_ctcte(a['ctcte']),
        :ctdsis => Date.today,
        :ctdcta => a['data'],
        :ctclau => idx,
        :ctpref => signe,
        :ctasse => num_ass,
        :cttext => a['com'],
        :ctimp => import
      }).save!

      # Falte brossa !

      clau_ass = clau_ass + 1
      num_ass = num_ass + 1
      wkey = idx
    }
  end




## Legacy setters
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
##
end
