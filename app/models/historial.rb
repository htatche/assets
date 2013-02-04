class Historial < ActiveRecord::Base
  belongs_to :compte, :foreign_key => 'ctkey'
  with_options :dependent => :destroy do |assoc|
    assoc.has_many :histgens
    assoc.has_many :histimps
    assoc.has_many :histpags
  end

  validates :impdoc,
    :presence => true,
    :numericality =>  true

  validates :datdoc,
    :presence => true

  validate do |f|
    if f.datdoc
      errors.add(:datdoc, 'No es una data') unless f.datdoc.is_a?(Date)
    end
  end

  def comentari
    if comdoc == ''
      numdoc
    else
      numdoc + '/' + comdoc
    end
  end

  def ctcte
    compte.ctcte
  end

  def self.buscarFactura(opckey, numdoc, ctcte)
    menudet = Menudet.find(opckey)
    grup = menudet.brakey if menudet.present?

    if numdoc and ctcte
      ctkey = Compte.completarCodi(grup, ctcte)
          
      Historial.where('empkey = ?', 1)
           .where('brakey = ?', grup)
           .where('numdoc = ?', numdoc)
           .where('ctkey = ?', ctkey)
    end

  end

  def comptabilitzar(nassent)
    compte = Compte.find(self.ctkey)
    w = Brain.getDeureHaver(self.brakey)

    mov = Moviment.new ({ 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => self.datdoc,
      :ctclau => 0,
      :ctpref => w[0] == 'D' ? -1 : 1,
      :ctasse => self.id,
      :numass => nassent,
      :cttext => self.comentari,
      :ctimp => self.impdoc
    })

    mov.save!
  end
end
