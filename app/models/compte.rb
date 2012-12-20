class Compte < ActiveRecord::Base
  belongs_to :pgc
  has_many :moviments

  #before_validation :formatCtcte, :on => :create

  validates :ctcte,
    :presence => true,
    :numericality => { :only_integer => true },
    :uniqueness => true,
    :length => { :maximum => Empresa.first.emploc }

  validates :ctdesc,
    :presence => true

  def ctfullname
    ctcte.to_s + ' - ' + ctdesc
  end

  def self.getCompte(ctcte)
    compte = find_by_ctcte(ctcte)
    pgc = Pgc.where('pgccla = ? AND pgccte = ?', 1, grup)

    raise 'No he trobat cap grup #{grup} dins del PGC'

    if compte.present?
      compte.id
    else
      compte = new({
        :ctemp => 1,
        :ctcte => @ctcte,
        :ctdesc => @ctdesc,
        :ctindi => '',
        :pgc_id => pgc.first.id
      })
      compte.save
      compte.id
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
    comptes = where('ctcte LIKE "?%"', grup.to_i)

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

  def self.checkAssistitErrors(opckey, ctcte, ctdesc, auto)
    grup = Brain.grupOri(opckey)
    lits = Menulit.find_by_opckey(opckey)

    errors = []

    if !ctcte.empty? and !ctdesc.empty?
      compte = Compte.where('ctcte = ?', ctcte)
      if compte.present?
        fields = {:ctcte => ctcte}
      else
        # Tenim que crear un nou compte
        codi = completarCodi(grup, ctcte)

        if codi == ''
          errors << {:field => lits.lit4,
                     :msg => 'te un format incorrecte'}
        else
          fields = {:ctcte => codi}
        end
      end
    elsif !ctcte.empty? and ctdesc.empty?
      compte = Compte.where('ctcte = ?', ctcte)
      if compte.present?
        fields = {:ctcte => ctcte}
      else
        errors << {:field => lits.lit5,
                  :msg => 'no pot estar buit'}
      end
    elsif ctcte.empty? and !ctdesc.empty?
      if auto
        fields = {:ctcte => Compte.generarNou(grup)}
      else
        errors << {:field => lits.lit4,
                   :msg => 'no pot estar buit'}
      end
    else
      errors << {:field => lits.lit4,
                 :msg => 'no pot estar buit'}
      errors << {:field => lits.lit5,
                 :msg => 'no pot estar buit'}
    end

    {:errors => errors, :fields => fields}
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
