class Compte < ActiveRecord::Base
  belongs_to :pgc
  has_many :moviments
  has_many :historials, :foreign_key => 'ctkey'
  has_many :histgens, :foreign_key => 'ctkey'
  has_many :histimps, :foreign_key => 'ctkey'
  has_many :histpags, :foreign_key => 'fpkey'

  validates :ctcte,
    :presence => true,
    :numericality => { :only_integer => true },
    :uniqueness => true

  validates :ctdesc,
    :presence => true

  def ctfullname
    ctcte.to_s + ' - ' + ctdesc
  end

  def self.find_by_ctcte_or_new(grup, ctcte, ctdesc)
    compte = where("ctcte LIKE '?'", ctcte)
    pgc_id = Parametre.pgc_id

    if compte.present?
      return compte
    else
      logger.debug pgc_id
      logger.debug grup
      pgc = Pgc.where("pgccla = ? AND pgccte = ?", pgc_id, grup)

      if pgc.present?
        return compte = new({
          :ctcte => ctcte,
          :ctdesc => ctdesc,
          :ctindi => '',
          :pgc_id => pgc.first.id
        })
      else
        raise "No he trobat el grup #{grup} dins del PGC"
      end
    end

  end

  def self.generarNou(grup)
    comptes = where("ctcte LIKE '?%'", grup.to_i)

    if comptes.present?
      noucompte = comptes.last.ctcte.to_i + 1
    else
      raise 'No existeix cap compte amb aquest grup'
    end    
  end

  def self.completarCodi(grup, ctcte)
    emploc = Parametre.long_compte
    grup = grup.to_s
    ctcte = ctcte.to_s

    if ctcte.numeric?
      if ctcte.length == emploc
        codi = ctcte
      else
        zeros = emploc - (grup.length + ctcte.length)
        ctcte = grup + ("0" * zeros) + ctcte
        
        codi = ctcte
      end
    else
      codi = ''
    end

    codi
  end

  # Formatejem el compte en format 'grup.compte'
  # S'utilitza desde la entrada de assentaments
  def self.formatejar_compte(compte)
    emploc = Parametre.long_compte

    if !Compte.where(:ctcte => compte).empty?
      return Compte.find_by_ctcte(compte).ctcte
    end

    if (compte =~ /^[0-9]+[.][0-9]+$/) && compte.length < emploc
      parts_compte = compte.split(".")

      if Pgc.where(:pgccte => parts_compte[0]).any?
        tamany_compte = parts_compte[0].length + parts_compte[1].length
        restant = emploc - tamany_compte

        if tamany_compte < emploc
          compte = parts_compte[0] + ('0' * restant) + parts_compte[1]
        end
      end
    end

    return compte
  end

end
