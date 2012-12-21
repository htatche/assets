class Historial < ActiveRecord::Base
  has_many :histgens

  validates :impdoc,
    :presence => true,
    :numericality =>  true

  validates :datdoc,
    :presence => true
  
  validate do |f|
    if f.datdoc
#errors.add(:datdoc, 'No es una data') unless f.datdoc.date?
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

  def compta(nassent)
    if brain = Brain.find_by_brakey(self.brakey)
      braini = brain.braini
    else
      raise 'Comptabilitzar Hist - Brain # #{brakey} inexistent'
    end

    if Compte.exists?(self.ctkey)
      compte = Compte.find(self.ctkey)
    else
      raise 'Comptabilitzar Hist - Compte # #{ctkey} inexistent'
    end

    #Assentament general
    mov = { 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => self.datdoc,
      :ctclau => 0,
      :ctpref => self.impdoc >= 0 ? 1 : -1,
      :ctasse => self.id,
      :numass => nassent,
      :cttext => self.comentari,
      :ctimp => self.impdoc
    }
    moviment = Moviment.new(mov)
    moviment.save
  end

  def comptabilitzar
    nctclau = 0
    num_ass = Moviment.getNewNumass
    w = Brain.getDeureHaver(self.brakey)

    if brain = Brain.find_by_brakey(self.brakey)
      braini = brain.braini
    else
      raise 'No sha trobat el brain'
    end

    if Compte.exists?(ctkey)
      compte = Compte.find(ctkey)
    else
      raise 'No sha trobat el compte'
    end

    nctclau = nctclau + 1
    wctkey_pra = compte.id
    wctcte_pra = compte.ctcte.to_s
    wctdesc_pra = compte.ctdesc
    import_doc = self.impdoc

    logger.debug 'start debugger'
    text_pra = self.numdoc
    wcomdoc = self.comdoc

    if text_pra != ''
      if braini != ''
        text_pra = braini + ':' + text_pra
      end
    end

    if wcomdoc == ''
      wcomdoc_final = text_pra
    else
      wcomdoc_final = text_pra + '/' + wcomdoc
    end

    if wcomdoc == ''
      if text_pra != ''
        wcomdoc = text_pra + '/' + wctcte_pra + '-' + wctdesc_pra
      else
        wcomdoc = wctcte_pra + '-' + wctdesc_pra
      end
    else
      if text_pra != ''
        wcomdoc = text_pra + '/' + wcomdoc
      end
    end

    logger.debug 'wcomdoc: ' + wcomdoc.inspect
    logger.debug 'wcomdoc_final: ' + wcomdoc_final.inspect
    logger.debug 'braini: ' + braini.inspect
    logger.debug 'text_pra: ' + text_pra.inspect

    #Assentament general
    mov = { 
      :ctkey => compte.id,
      :ctdsis => Date.today,
      :ctdcta => self.datdoc,
      :ctclau => nctclau,
      :ctpref => self.impdoc >= 0 ? 1 : -1,
      :ctasse => self.id,
      :numass => num_ass,
      :cttext => wcomdoc_final,
      :ctimp => self.impdoc
    }
    moviment = Moviment.new(mov)
    moviment.save
      
    #Contrapartida
    histgens = Histgen.where('historial_id = ?', self.id)

    histgens.each { |i|
      
      wcomen = i.comen.blank? ? '' : i.comen

      if wcomen.blank?
        wcomen = wcomdoc
      else
        wcomen = text_pra + '/' + wcomen
      end

      lcompte = Compte.find_if_exists(i.ctkey)

      if lcompte.present?
        nctclau = nctclau + 1
        w2_old = w[2]

        sSql = 'brddes = Mid(' + lcompte.ctcte.to_s.strip
        sSql = sSql + ', 1, Length(brddes))'
        braindets = Braindet.where('brakey = ?', self.brakey)
                            .where(sSql)

        if braindets.present?
            brdpde = braindets.first.brdpde
            w[2] = brdpde == 1 ? 'D' : 'H'
        end

        mov = { 
          :ctkey => lcompte.id,
          :ctdsis => Date.today,
          :ctdcta => self.datdoc,
          :ctclau => nctclau,
          :ctpref => w[2] == 'D' ? -1 : 1,
          :ctasse => self.id,
          :numass => num_ass,
          :cttext => wcomen,
          :ctimp => i.import
        }
        moviment = Moviment.new(mov)
        moviment.save

        w[2] = w2_old
      end
    }

    #Impostos
    histimps = Histimp.where('historial_id = ?', self.id)

    histimps.each { |i|
        
      lcompte = Compte.find_if_exists(i.ctkey)

      nctclau = nctclau + 1

      mov = Moviment.new({
        :ctkey => lcompte.id,
        :ctdsis => Date.today,
        :ctdcta => self.datdoc,
        :ctclau => nctclau,
        :ctpref => i.impbas >= 0 ? 1 : -1,
        :ctasse => self.id,
        :numass => num_ass,
        :cttext => wcomdoc,
        :ctimp => i.impbas
      })

      moviment.save
    }

    #Pagaments
    histpags = Histpag.where('historial_id = ?', self.id)
    wimport_pagat = 0

    histpags.each { |i|

      wcomen = i.comen.blank? ? '' : i.comen
      wimport_pagat = wimport_pagat + i.import

      if wcomen.blank?
        wcomen = wcomdoc
      else
        wcomen = text_pra + '/' + wcomen
      end

      lcompte = Compte.find_if_exists(i.fpkey)

      nctclau = nctclau + 1
      mov = { 
        :ctdsis => Date.today,
        :ctdcta => i.datven,
        :ctclau => nctclau,
        :ctpref => i.import >= 0 ? 1 : -1,
        :ctasse => self.id,
        :numass => num_ass,
        :ctimp => i.import
      }

      mov[:ctkey] = lcompte.id
      mov[:cttext] = wcomen

      moviment = Moviment.new(mov)
      moviment.save

      nctclau = nctclau + 1
      mov[:ctclau] = nctclau
      mov[:ctkey] = compte.id
      mov[:cttext] = wcomdoc_final

      moviment = Moviment.new(mov)
      moviment.save
    }
  end
end
