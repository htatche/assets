class Compte < ActiveRecord::Base
  belongs_to :pgc
  has_many :moviments
  has_many :historials, :foreign_key => 'ctkey'

  #before_validation :formatCtcte, :on => :create

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
    compte = find_by_ctcte(ctcte)

    if compte.present?
      return compte

    else
      pgc = Pgc.where('pgccla = ? AND pgccte = ?', 1, grup)

      if pgc.present?
        return compte = new({
          :ctcte => ctcte,
          :ctdesc => ctdesc,
          :ctindi => '',
          :pgc_id => pgc.first.id
        })
      else
        raise 'No he trobat el grup #{grup} dins del PGC'
      end
    end

  end

  def self.find_if_exists(id)
    if Compte.exists?(id)
      Compte.find(id)
    else
      raise 'No sha trobat el compte'
    end
  end

  def self.getCompteId(ctcte)
    if compte = Compte.find_by_ctcte(ctcte)
      compte = compte.id
    else
      raise 'Compte ' + ctcte  + ' inexistent'
    end

    compte
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

    empresa = Empresa.find(1)
    grup = grup.to_s
    ctcte = ctcte.to_s

    if ctcte.numeric?
      if ctcte.length == empresa.emploc
        codi = ctcte
      else
        zeros = empresa.emploc - (grup.length + ctcte.length)
        ctcte = grup + ("0" * zeros) + ctcte
        
        codi = ctcte
      end
    else
      codi = ''
    end

    codi
  end

# Per ara el desactivem mentres programem els assistits
#def formatCtcte
#  @empresa = Empresa.first
#    @category = Pgc.find(pgc_id).pgccte
#
#   if ctcte.is_a? Integer
#     # We get the full compte format, filling remaining space between category and compte with 0's
#     @spaceToFill = @empresa.emploc - (@category.to_s.length + ctcte.to_s.length)
#     self.ctcte = @category.to_s + ("0" * @spaceToFill) + ctcte.to_s
#   else
#     errors.add(:ctcte, 'is not numeric')
#   end
# end

  # Formats ctcte directly in new assentament form
  def self.autoCompleteCtcte(numCompte)
    @empresa = Empresa.first

    if not Compte.where(:ctcte => numCompte).empty? then
      Compte.find_by_ctcte(numCompte).ctcte
    else
      if (numCompte =~ /^[0-9]+[.][0-9]+$/) and numCompte.length < @empresa.emploc then
        if @parts_numCompte = numCompte.split(".") then
          if Pgc.where(:pgccte => @parts_numCompte[0]).empty? then
            # El format no es correcte
          else
            # El format es correcte i el prefix PGC també

            # Omplenem amb els zeros que faltin
            @tamany_numCompte = @parts_numCompte[0].length + @parts_numCompte[1].length
            @restant = @empresa.emploc - @tamany_numCompte

            if @tamany_numCompte < @empresa.emploc then
              # Bingo !
              @parts_numCompte[0] + "0" * @restant + @parts_numCompte[1]
            end

          end
        end
      end
    end

  end

  # NO S'UTILITZA
  # Validar compte al vol
  def self.check_ctcte(empKey, numCompte)
    @empresa = Empresa.where(:empKey => empKey).first

    if not Compte.where(:ctcte => numCompte).empty? then
      @response = ""
    else
      if (numCompte =~ /^[0-9]+[.][0-9]+$/) and numCompte.length < @empresa.emploc then
        if @parts_numCompte = numCompte.split(".") then
          if Pgc.where(:pgccte => @parts_numCompte[0]).empty? then
            @response = "Aquest compte es erroni !"
          else
            # El format es correcte i el prefix PGC també

            # Omplenem amb els zeros que faltin
            @tamany_numCompte = @parts_numCompte[0].length + @parts_numCompte[1].length
            @restant = @empresa.emploc - @tamany_numCompte

            if @tamany_numCompte < @empresa.emploc then
                @compte = @parts_numCompte[0] + "0" * @restant + @parts_numCompte[1]
            end

            # Un cop el tenim formatejat correctament, cal saber si existeix o no
            # abans de crearlo 14:21
            if Compte.where(:ctcte => @compte).empty? then
              @response = "Aquest compte es nou !"
            else
              @response = ""
            end

          end
        end
      else
        # Aqui cal posar un else if abans, on es chequeji que no hagi posat el compte
        # en format normal 70000010 pero que el compte sigui nou i no estigui a la taula
        @response = "Aquest compte es erroni !"
      end
    end
  end

end
