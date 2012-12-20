class Assentament
  
  def initialize(params)
    @errors = []
    
    @ctcte = params[:ctcte] || ''
    @ctdesc = params[:ctdesc] || ''
    @numdoc = params[:numdoc] || ''
    @opckey = params[:opckey]
    @import = params[:import]
    @date = params[:date]
    @comentari = params[:comentari] || ''
    @auto = params[:assignar_codi_auto] || true

    @contrapartides = params[:apunts] || []
    @impostos = params[:imp] || []
    @pagaments = params[:pag] || []

    @grup = Brain.grupOri(@opckey)
    @lits = Menulit.find_by_opckey(@opckey)

    @numcompte = ''
  end

  def ctcte
    @ctcte
  end

  def ctdesc
    @ctdesc
  end

  def grup
    @grup
  end

  def opckey
    @opckey
  end

  def import
    if @import
      @import.sanitizeCurrency
    else
      import = ''
    end
  end

  def validateCompte

    if !@ctcte.empty? and !@ctdesc.empty?
      compte = Compte.where('ctcte = ?', @ctcte)
      if compte.present?
        @numcompte = @ctcte
      else
        # Tenim que crear un nou compte
        codi = Compte.completarCodi(@grup, @ctcte)

        if codi == ''
          errors = [{:field => @lits.lit4,
                    :msg => 'te un format incorrecte'}]
        else
          @numcompte = codi
        end
      end
    elsif !@ctcte.empty? and @ctdesc.empty?
      compte = Compte.where('ctcte = ?', @ctcte)
      if compte.present?
        @numcompte = @ctcte
      else
        errors = [{:field => @lits.lit5,
                  :msg => 'no pot estar buit'}]
      end
    elsif @ctcte.empty? and !@ctdesc.empty?
      if @auto
        @ctcte = Compte.generarNou(@grup)
      else
        errors = [{:field => @lits.lit4,
                   :msg => 'no pot estar buit'}]
      end
    else
      errors = [{:field => @lits.lit4,
                 :msg => 'no pot estar buit'},
                {:field => @lits.lit5,
                 :msg => 'no pot estar buit'}]
    end

    return errors
  end

  def validateNumdoc
    if Historial.buscarFactura(@opckey, @numdoc, @ctcte)
      return {:field => @lits.lit3, :msg => 'Factura duplicada'}
    end
  end

  def validateAssGeneral
    @general = Historial.new({
      :empkey => 1,
      :brakey => @grup,
      :ctkey => 0,
      :numdoc => @numdoc,
      :datdoc => @date,
      :datsis => Date.today,
      :impdoc => @import,
      :comdoc => @comentari,
      :optimp => 1,
      :optpag => 1,
      :optreb => 0,
      :indcom => 0,
      :datcom => '',
      :ctasse => 0
    })
    
    @general.valid?
    if @general.errors.any?
      errors = []
      errors_gen = @general.errors.messages
      errors_gen.each { |i|
        i[1].each { |j|
          errors << {:field => lits.lit7, :msg => j} if i[0] == :impdoc
          errors << {:field => lits.lit6, :msg => j} if i[0] == :datdoc
        }
      }
    end

    return errors
  end

  def validateContrapartida
    if @contrapartides.present?

      errors = []
      @contrapartides.each_with_index{ |i, index|

        @contrapartides[index] = Histgen.new({
          :historial_id => 0,
          :ctkey => Compte.getCompteId(i[1][:compte]),
          :hislin => index,
          :import => i[1][:import].sanitizeCurrency,
          :comen => i[1][:comment]
        }) 
        
        errors << @contrapartides[index].errorPresenter(index)
      }

      return errors
    end
  end

  def validateAll
    @errors << validateCompte
    @errors << validateNumdoc
  end

end
