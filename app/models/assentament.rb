class Assentament
  
  def initialize(params)
    @errors = []
    
    @ctcte = params[:ctcte] || ''
    @ctdesc = params[:ctdesc] || ''
    @numdoc = params[:numdoc] || ''
    @opckey = params[:opckey]
    @import = params[:import].sanitizeCurrency
    @date = params[:date]
    @comentari = params[:comentari] || ''
    @auto = params[:assignar_codi_auto] || true

    @contrapartides_param = params[:apunts] || []
    @impostos_param = params[:imp] || []
    @pagaments_param = params[:pag] || []

    @contrapartides = []
    @impostos = []
    @pagaments = []

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
      @import = ''
    end
  end

  def compte
    @compte
  end

  def errors
    @errors
  end

  def getCompte
    @compte = Compte.find_by_ctcte_or_new(@grup, @numcompte, @ctdesc)
  end

  def validateCompte

    errors = []

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
    errors = {}
    if Historial.buscarFactura(@opckey, @numdoc, @ctcte).present?
      error = {:field => @lits.lit3, :msg => 'Factura duplicada'}
    end

    return error
  end

  def validateAssGeneral
    errors = []

    @general = Historial.new({
      :brakey => @grup,
#:ctkey => 0,
      :numdoc => @numdoc,
      :datdoc => @date,
      :datsis => Date.today,
      :impdoc => @import,
      :comdoc => @comentari,
      :optimp => 1,
      :optpag => 1,
      :optreb => 0,
      :indcom => 0,
      :datcom => ''
    })
    
#@general.valid?
    @general.save!
    if @general.errors.any?
      errors_gen = @general.errors.messages
      errors_gen.each { |i|
        i[1].each { |j|
          errors << {:field => @lits.lit7, :msg => j} if i[0] == :impdoc
          errors << {:field => @lits.lit6, :msg => j} if i[0] == :datdoc
        }
      }
    end

    return errors
  end

  def validateContrapartida
    errors = []

    if @contrapartides.present?

      @contrapartides.each_with_index{ |i, index|

        @contrapartides[index] = Histgen.new({
#:historial_id => 0,
          :ctkey => Compte.getCompteId(i[1][:compte]),
          :hislin => index,
          :import => i[1][:import].sanitizeCurrency,
          :comen => i[1][:comment]
        }) 
        
        errors << @contrapartides[index].errorPresenter(index)
      }

    end
    
    return errors
  end

  def validateImpostos
    errors = []

    if @impostos_param.present?
      firstrow = @impostos_param.first[1]['import']

      # Comprovem que s'hagi omplert algun import
      unless  @impostos_param.length == 1 && firstrow.sanitizeCurrency.to_f == 0
        @impostos_param.each_with_index { |i, index|
          @impostos[index] = Histimp.new({
#      :historial_id => 0,
            :hislin => index,
            :ctkey => Compte.getCompteId(i[1][:compte]),
            :impbas => 'a' # i[1][:import].sanitizeCurrency
          }) 

          errors << @impostos[index].errorPresenter(index)
        } 
      end
    end

    return errors
  end

  def validateInputs
    errors = validateCompte
    errors_push(errors)

    errors = validateNumdoc
    errors_push(errors.to_a)
  end

  def validateAll

    errors = validateAssGeneral
    errors_push(errors)

#    errors = validateContrapartida
#    errors_push(errors)

#errors = validateImpostos
#    errors_push(errors)
  end

  def comptabilitzarAll
      
  end

  def errors_push(errors)
    @errors << errors if errors.any?
  end


  def destroy

  end
end
