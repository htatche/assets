class AssistitsController < ApplicationController
  respond_to :html, :json

  def show
    @menuOptions = Menudet.where('mnukey = ?', params[:option])

    if @menuOptions.present? 
      render :partial => 'show',
             :locals => {:menuOptions => @menuOptions}
    end
 
  end

  def create
    numdoc = params[:numdoc]
    ctcte = params[:ctekey]
    ctdesc = params[:ctdesc]
    opckey = params[:opckey]
    auto = params[:assignar_codi_auto]

    lits = Menulit.find_by_opckey(opckey)
    menudet = Menudet.find(opckey)

    grup = menudet.brakey if menudet.present?

    # Check compte / descripcio
    checkcompte = Compte.checkAssistitErrors(opckey, ctcte, ctdesc, auto)
    
    errors = checkcompte[:errors]
    fields = checkcompte[:fields]
    
    # Check compte si necessari
    if errors.empty?
      unless Compte.find_by_ctcte(fields[:ctcte]).present?
        pgc = Pgc.where('pgccla = ? AND pgccte = ?', 1, grup)
        pgckey = pgc.first.id
          
        compteparams = {
          :ctemp => 1,
          :ctcte => fields[:ctcte],
          :ctdesc => params[:ctdesc],
          :ctindi => '',
          :pgc_id => pgckey
        }

        @compte = Compte.new(compteparams)
      end

      # Check numdoc
      if buscarFactura(numdoc, ctcte, opckey)
        errors << {:field => lits.lit3, :msg => 'Factura duplicada'}
      end
    
      # Parse import from input
      if params[:import]
        import = params[:import].sanitizeCurrency
      else
        import = ''
      end

      histparams = {
        :empkey => 1,
        :brakey => grup,
        :ctkey => 0,
        :numdoc => numdoc,
        :datdoc => params[:date],
        :datsis => Date.today,
        :impdoc => import,
        :comdoc => params[:comment],
        :optimp => 1,
        :optpag => 1,
        :optreb => 0,
        :indcom => 0,
        :datcom => '',
        :ctasse => 0
      }

      @historial = Historial.new(histparams)
    
      # Check data, import via Historial
      @historial.valid?
      if @historial.errors.any?
        histerrors = @historial.errors.messages
        histerrors.each { |i|
          i[1].each { |j|
            errors << {:field => lits.lit7, :msg => j} if i[0] == :impdoc
            errors << {:field => lits.lit6, :msg => j} if i[0] == :datdoc
          }
        }
      end

      # Check apunts
      if params[:apunt]
        @apunts = []
        params[:apunt].each_with_index{ |i, index|

          @apunts[index] = Histgen.new({
            :historial_id => 0,
            :ctkey => Compte.getCompteId(i[1][:compte]),
            :hislin => index,
            :import => i[1][:import].sanitizeCurrency,
            :comen => i[1][:comment]
          }) 
          
          errors << @apunts[index].errorPresenter(index)
        }
      end

      if menudet.opcfrm == 'frm_p3_alta'

        # Check impostos
        if params[:imp]
          firstrow = params[:imp].first[1]['import']

          # Comprovem que s'hagi omplert algun import
          unless  params[:imp].length == 1 && firstrow.sanitizeCurrency.to_f == 0
            @impostos = []
            params[:imp].each_with_index { |i, index|
              @impostos[index] = Histimp.new({
                :historial_id => 0,
                :hislin => index,
                :ctkey => Compte.getCompteId(i[1][:compte]),
                :impbas => i[1][:import].sanitizeCurrency
              }) 

              errors << @impostos[index].errorPresenter(index)
            } 
          end
        end

        # Check pagaments
        if params[:pag]
          firstrow = params[:pag].first[1]['date'].strip

          unless params[:pag].length == 1 and firstrow.empty?
            @pagaments = []
            params[:pag].each_with_index { |i, index|
      
              @pagaments[index] = Histpag.new({
                :historial_id => 0,
                :hislin => index,
                :fpkey => Compte.getCompteId(i[1][:compte]),
                :import => i[1][:import].sanitizeCurrency,
                :datven => i[1][:date],
              }) 

              errors << @pagaments[index].errorPresenter(index)
            } 
          end
        end
      end

    end

    errors = errors.flatten
    if errors.any?
      render :json => errors.to_json, :status => :unprocessable_entity
    else

      nassent = Moviment.getNewNumass

      histmov = @historial.comptabilitzar (nassent)
       
    
      begin 
        Moviment.comptabilitzar(@historial, 
                                @apunts,
                                @impostos,
                                @pagaments)
      rescue => e
        errors << {:field => 'Comptabilitzar',
                   :msg => 'Error'}
        render :json => errors.to_json,
               :status => :unprocessable_entity

      end

      if @compte
        @compte.save
        ctkey = @compte.id
      else
        ctkey = Compte.getCompteId(fields[:ctcte])
      end

      @historial.ctkey = ctkey
      @historial.save

      if @apunts
        @apunts.each { |i|
          i.historial_id = @historial.id
          i.save
        } 
      end

      if @impostos
        @impostos.each { |i|
          i.historial_id = @historial.id
          i.save
        } 
      end

      if @pagaments
        @pagaments.each { |i|
          i.historial_id = @historial.id
          i.save
        } 
      end

      render :text => lits.lit15
    end

  end

  def assistit
    @opckey = params[:assistit].to_i
    @nrow = '0'

    @assistit = Menudet.find(@opckey)
    @frmLabels = Menulit.getFormLabels(@opckey)

    @grups_condition = buscarGrupComptable(@opckey)
    @comptes_desti = Compte.where('ctemp = ?', 1)
                           .where(@grups_condition)

    if @assistit.opcfrm == 'frm_p3_alta'
      @brain = Brain.find_by_brakey(@assistit.brakey)
      @grupimpostos = @brain.braimp
      @gruppagaments = @brain.brapag

      @comptes_impostos = Compte.where('ctemp = ? AND ctcte LIKE "?%"',
                                        1,
                                        @grupimpostos.to_i)
      @comptes_pagaments = Compte.where('ctemp = ? AND ctcte LIKE "?%"',
                                      1,
                                      @gruppagaments.to_i)
    end

    if @assistit.present? 
      render :partial => 'assistits/'+@assistit.opcfrm,
             :locals => {:frmLabels => @frmLabels,
                         :opckey => @opckey.to_s}
    end
 
  end

  def buscarGrupComptable(opckey)
    @grups_condition = ''
    @grup_comptable = Menudet.find(opckey)

    if @grup_comptable.present?
      @brain = Brain.where('brakey = ?', @grup_comptable.brakey)
    end

    if @brain.present?
      @brain = @brain.first

      @grups_condition = 'ctcte LIKE "' + @brain.brades + '%"'
      @braindet = Braindet.where('brakey = ?', @grup_comptable.brakey)
                          .order('brdlin')

      @braindet.each{ |i| 
        @grups_condition += ' OR ctcte LIKE "' + i.brddes + '%"' if i.brddes
      }
    end

    @grups_condition
  end

  def getCodiCompte
    opckey = params[:opckey]
    ctcte = params[:ctcte]
    grup_comptable = Brain.grupOri(opckey)

    codi = Compte.completarCodi(grup_comptable, ctcte)

    @compte = Compte.select('ctcte, ctdesc')
                    .where('ctemp = ? AND ctcte = ?', 1, codi)

    if @compte.present?
      render :json => @compte.first.to_json
    else
      render :text => 'Codi incorrecte', :status => 500
    end

  end

  def buscarFactura(numdoc, ctcte, opckey)
    menudet = Menudet.find(opckey)
    grup = menudet.brakey if menudet.present?

    if numdoc and ctcte
      ctkey = Compte.completarCodi(grup, ctcte)
          
      Historial.where('empkey = ?', 1)
           .where('brakey = ?', grup)
           .where('numdoc = ?', numdoc)
           .where('ctkey = ?', ctkey).first
    end
  end

  def getFacturaDuplicada
    numdoc = params[:numdoc]
    ctcte = params[:ctcte]
    opckey = params[:opckey]

    if numdoc and ctcte
      grup = Brain.grupOri(opckey)
      ctkey = Compte.completarCodi(grup, ctcte)
      @compte = Compte.where('ctemp = ? AND ctcte = ?', 1, ctkey)

      if @compte.present?
        @compte = @compte.first
        @compte.ctcte.nil? ? 0: @compte.ctcte
      end
    
      @historial = buscarFactura(numdoc,ctcte,opckey)

      if @historial.present?
        render :partial => 'factura_duplicada'
      else
        render :text => ''
      end
    end

  end

  def getComptes
    opckey = params[:opckey]

    grup_comptable = Brain.grupOri(opckey)
    @comptes = Compte.select('ctcte, ctdesc')
                     .where('ctemp = ? AND ctcte LIKE "?%"',
                            1, grup_comptable.to_i)

    if @comptes.present?
      @json = []
      @comptes.each{ |i|
        html = i.ctcte.to_s + ' - ' + i.ctdesc
        @json << {html: html, title: i.ctcte.to_s}  
      }

      render :json => @json
    else
      render :json => {}
    end
  end

  def getAssentament
    @opckey = params[:opckey].to_i
    @nrow = params[:nrows]

    @assistit = Menudet.find(@opckey)
    @frmLabels = Menulit.getFormLabels(@opckey)

    @grups_condition = buscarGrupComptable(@opckey)
    @comptes_desti = Compte.where(@grups_condition)
    
    render :partial => 'assistits/assentament'
  end

  def getImpost
    @opckey = params[:opckey].to_i
    @nrow = params[:nrows]

    @assistit = Menudet.find(@opckey)
    @frmLabels = Menulit.getFormLabels(@opckey)

    @brain = Brain.find_by_brakey(@assistit.brakey)
    @grupimpostos = @brain.braimp.to_i
    @comptes_impostos = Compte.where('ctcte LIKE "?%"',
                                      @grupimpostos)
    
    render :partial => 'assistits/impost'
  end

  def getPagament
    @opckey = params[:opckey].to_i
    @nrow = params[:nrows]

    @assistit = Menudet.find(@opckey)
    @frmLabels = Menulit.getFormLabels(@opckey)

    @brain = Brain.find_by_brakey(@assistit.brakey)
    @gruppagaments = @brain.brapag.to_i
    @comptes_pagaments = Compte.where('ctcte LIKE "?%"',
                                      @gruppagaments)
    
    render :partial => 'assistits/pagament'
  end
end
