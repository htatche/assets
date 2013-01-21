class Histpag < ActiveRecord::Base
  include Assistit

  belongs_to :historial
  belongs_to :compte, :foreign_key => 'fpkey'

  validates :historial_id,
    :presence => true,
    :on => :save
  validates :hislin,
    :presence => true
  validates :fpkey,
    :presence => true
  validates :datven,
    :presence => true
  validates :import,
    :presence => true
  validates :import, :numericality => true, :if => :import
  validates :datven,
    :presence => true
  validate :datven_is_date, :if => :datven

  def datven_is_date
    if !datven.is_a?(Date)
      errors.add(:datven, 'no es una data correcta') 
    end
  end

  def validationTitle
    'Pagament'
  end

  def comentari(comdoc, text_pra)
    comen = comen.blank? ? '' : comen

    if comen.blank?
      comdoc
    else
      text_pra + '/' + comen
    end
  end

  def comptabilitzar (nassent, nctclau, comdoc, text_pra)

    compte = Compte.find(self.fpkey)
    w = Brain.getDeureHaver(historial.brakey)

    mov = { 
      :ctdsis => Date.today,
      :ctdcta => historial.datdoc,
      :ctpref => w[3] == 'D' ? -1 : 1,
      :ctasse => self.id,
      :numass => nassent,
      :ctimp => import
    }

    mov[:ctclau] = nctclau
    mov[:ctkey] = compte.id
    mov[:cttext] = comentari(comdoc, text_pra) 

    moviment = Moviment.new(mov)
    moviment.save!

    nctclau = nctclau + 1

    mov[:ctclau] = nctclau
    mov[:ctkey] = historial.ctkey
    mov[:cttext] = historial.comentari

    moviment = Moviment.new(mov)
    moviment.save!

    return nctclau
  end
end
