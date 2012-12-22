class Histimp < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true, :on => :save
  validates :hislin,
    :presence => true
  validates :ctkey,
    :presence => true
  validates :impbas,
    :presence => true
  validates :impbas, :numericality => true, :if => :impbas

  def validationTitle
    'Impost'
  end

  def comptabilitzar (nassent, nctclau)

    compte = Compte.find(self.ctkey)
    w = Brain.getDeureHaver(historial.brakey)

    mov = Moviment.new ({ 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => historial.datdoc,
      :ctclau => nctclau,
      :ctpref => w[2] == 'D' ? -1 : 1,
      :ctasse => self.id,
      :numass => nassent,
      :ctimp => impbas
    })

    mov.save!
  end

end
