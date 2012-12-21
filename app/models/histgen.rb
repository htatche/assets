class Histgen < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true,
    :on => :save
  validates :hislin,
    :presence => true
  validates :ctkey,
    :presence => true
  validates :import,
    :presence => true
  validates :import, :numericality => true, :if => :import

  def self.validationTitle
    'Apunt'
  end

  def setComentari (historial)
    comment = comen.blank? ? '' : comen

    if comment.blank?
      comment = historial.comdoc
    else
      comment = historial.numdoc + '/' + comment
    end
  end

  def comptabilitzar (nassent, nctclau, historial)

    if Compte.exists?(self.ctkey)
      compte = Compte.find(self.ctkey)
    else
      raise 'Comptabilitzar Hist - Compte # "#{ctkey}" inexistent'
    end

    w = Brain.getDeureHaver(historial.brakey)

    nctclau = nctclau + 1

    sSql = 'brddes = Mid(' + compte.ctcte.to_s.strip
    sSql = sSql + ', 1, Length(brddes))'
    braindets = Braindet.where('brakey = ?', historial.brakey)
                        .where(sSql)

    if braindets.present?
        brdpde = braindets.first.brdpde
        w[2] = brdpde == 1 ? 'D' : 'H'
    end

    mov = Moviment.new ({ 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => historial.datdoc,
      :ctclau => nctclau,
      :ctpref => w[2] == 'D' ? -1 : 1,
      :ctasse => self.id,
      :numass => nassent,
      :cttext => setComentari(historial),
      :ctimp => import
    })

    mov.save
  end

end
