class Assentament
  
  def initialize(params)
    @errors = []
    
    @ctcte = params[:ctekey] || params[:compte] || ''
    @ctdesc = params[:ctdesc] || ''
    @numdoc = params[:numdoc] || ''
    @opckey = params[:opckey]
    @date = params[:date]
    @comment = params[:comment] || ''
    @auto = params[:assignar_codi_auto] ? true : false

    if params[:import]
      @import = params[:import].sanitizeCurrency
    else
      @import = ''
    end

    @contrapartides_param = params[:apunt] || []
    @impostos_param = params[:imp] || []
    @pagaments_param = params[:pag] || []

    @general = {}
    @contrapartides = []
    @impostos = []
    @pagaments = []

    @brakey = Menudet.find(@opckey).brakey
    @grup = @brakey

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

  def validateCompte

    errors = []

    if !@ctcte.empty? and !@ctdesc.empty?
      compte = Compte.where('ctcte = ?', @ctcte)
      if compte.present?
        @numcompte = compte.first.ctcte

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
        braori = Brain.find_by_brakey(@grup).braori
        @numcompte = Compte.generarNou(braori)
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
    if @ctcte.present? &&
       Historial.buscarFactura(@opckey, @numdoc, @ctcte).present?
      error = {:field => @lits.lit3, :msg => 'Factura duplicada'}
    end

    return error
  end

  def validateAssGeneral
    errors = []

    @general = Historial.new({
      :brakey => @grup,
      :numdoc => @numdoc,
      :datdoc => @date,
      :datsis => Date.today,
      :impdoc => @import,
      :comdoc => @comment,
      :optimp => 1,
      :optpag => 1,
      :optreb => 0,
      :indcom => 0,
      :datcom => ''
    })
    
    @general.valid?
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

    if @contrapartides_param.present?

      @contrapartides_param.each_with_index{ |i, index|

        @contrapartides[index] = Histgen.new({
          :ctkey => Compte.find_by_ctcte(i[1][:compte]).id,
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
            :hislin => index,
            :ctkey => Compte.find_by_ctcte(i[1][:compte]).id,
            :impbas => i[1][:import].sanitizeCurrency
          }) 

          errors << @impostos[index].errorPresenter(index)
        } 
      end
    end

    return errors
  end

  def validatePagaments
    errors = []

    if @pagaments_param.present?
      firstrow = @pagaments_param.first[1]['date'].strip

      unless @pagaments_param.length == 1 and firstrow.empty?
        @pagaments_param.each_with_index { |i, index|
    
          @pagaments[index] = Histpag.new({
            :hislin => index,
            :fpkey => Compte.find_by_ctcte(i[1][:compte]).id,
            :import => i[1][:import].sanitizeCurrency,
            :datven => i[1][:date],
          }) 

          errors << @pagaments[index].errorPresenter(index)
        } 
      end
    end

    return errors
  end

  def validateAll
    errors = validateCompte

    # No permet que es continuin executant les
    # validacions si el compte es incorrecte
    if errors.any?
      return errors_push(errors)
    end

    errors = validateNumdoc
    errors_push(errors.to_a)

    errors = validateAssGeneral
    errors_push(errors)

    errors = validateContrapartida
    errors_push(errors)

    errors = validateImpostos
    errors_push(errors)

    errors = validatePagaments
    errors_push(errors)
  end

  def save
    nassent = Moviment.getNewNumass
    braori = Brain.find_by_brakey(@general.brakey).braori

    compte = Compte.find_by_ctcte_or_new(braori, @numcompte, @ctdesc)

    if compte.new_record?
      compte.save
    end

    @general.ctkey = compte.id
    @general.save

    @contrapartides.each { |i|
      i.historial_id = @general.id
      i.save!
    }
    @impostos.each { |i|
      i.historial_id = @general.id
      i.save!
    }
    @pagaments.each { |i|
      i.historial_id = @general.id
      i.save!
    }
      
  end

  def buildCommentForMoviment

    brain = Brain.find_by_brakey(@general.brakey)
    braini = brain.braini

    compte = Compte.find(@general.ctkey)

    text_pra = @general.numdoc
    comdoc = @general.comdoc

    if text_pra != ''
      if braini != ''
        text_pra = braini + ':' + text_pra
      end
    end

    if comdoc == ''
      if text_pra != ''
        comdoc = text_pra + '/' + compte.ctcte + '-' + compte.ctdesc
      else
        comdoc = compte.ctcte + '-' + compte.ctdesc
      end
    else
      if text_pra != ''
        comdoc = text_pra + '/' + comdoc
      end
    end

    @text_pra = text_pra
    @comdoc = comdoc

  end

  def comptabilitzar
    buildCommentForMoviment
    nassent = Moviment.getNewNumass
    nctclau = 0

    @general.comptabilitzar (nassent)

    @contrapartides.each { |i|
      nctclau = nctclau + 1
      i.comptabilitzar(nassent, nctclau, @comdoc, @text_pra)
    }

    @impostos.each { |i|
      nctclau = nctclau + 1
      i.comptabilitzar(nassent, nctclau)
    }

    @pagaments.each { |i|
      nctclau = nctclau + 1
      nctclau = i.comptabilitzar(nassent, nctclau, @comdoc, @text_pra)
    }
    
  end

  def save_and_comptabilitzar
    Historial.transaction do
      save
      comptabilitzar
    end
  end

  def errors_push(errors)
    @errors << errors if errors.any?
  end


  def destroy

  end
end
