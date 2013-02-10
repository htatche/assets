class Histgen < ActiveRecord::Base
  include Assistit

  belongs_to :historial
  belongs_to :compte, :foreign_key => 'ctkey'

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

  def comentari (comdoc, text_pra)
    if comen.blank?
      comdoc
    else
      text_pra + '/' + comen
    end
  end

  def comptabilitzar (nassent, nctclau, comdoc, text_pra)

    compte = Compte.find(self.ctkey)
    w = Brain.getDeureHaver(historial.brakey)

    sSql = "brddes = Substr('#{compte.ctcte.to_s.strip}'"
    sSql = sSql + ", 1, Length(brddes))"
    braindets = Braindet.where('brakey = ?', historial.brakey)
                        .where(sSql)

    if braindets.present?
      brdpde = braindets.first.brdpde
      w[1] = brdpde == 1 ? 'D' : 'H'
    end

    mov = Moviment.new ({ 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => historial.datdoc,
      :ctclau => nctclau,
      :ctpref => w[1] == 'D' ? -1 : 1,
      :ctasse => self.id,
      :numass => nassent,
      :cttext => comentari(comdoc, text_pra),
      :ctimp => import
    })

    mov.save!
  end

end
