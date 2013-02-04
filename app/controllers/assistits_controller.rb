class AssistitsController < ApplicationController
  respond_to :html, :json

  def show
    @mnukey = params[:option]
    @menuOptions = Menudet.where('mnukey = ? AND opcmodul = ?',
                                 @mnukey,
                                 'assistit')

    if @menuOptions.present? 
      render :partial => 'show',
             :locals => {:menuOptions => @menuOptions}
    end
 
  end

  def create
    opckey = params[:opckey]
    lits = Menulit.find_by_opckey(opckey)
    menudet = Menudet.find(opckey)

    grup = menudet.brakey if menudet.present?

    ass = Assentament.new(params)
    ass.validateAll

    ass.errors.flatten!
    if ass.errors.any?
      render :json => ass.errors.to_json,
             :status => :unprocessable_entity
    else
      ass.save_and_comptabilitzar

      render :text => 'ok'
    end
  end

  def destroy
    historial = Historial.find(params[:id])

    if historial.destroy
      render :json => historial, :status => :ok
    else
      render :status => :internal_server_error
    end
  end

  def update
    opckey = params[:opckey]
    lits = Menulit.find_by_opckey(opckey)
    menudet = Menudet.find(opckey)

    grup = menudet.brakey

    ass = Assentament.new(params)
    ass.validateAll

    ass.errors.flatten!
    if ass.errors.any?
      render :json => ass.errors.to_json,
             :status => :unprocessable_entity
    else
      ass.save_and_comptabilitzar
      Historial.find(params[:id]).destroy

      render :text => 'ok'
    end

  end

  def assistit
    @opckey = params[:assistit].to_i
    @nrow = '0'

    @assistit = Menudet.find(@opckey)
    @frmLabels = Menulit.getFormLabels(@opckey)

    @grups_condition = buscarGrupComptable(@opckey)
    @comptes_desti = Compte.where(@grups_condition)

    if @assistit.opcfrm == 'frm_p3_alta'
      brain = Brain.find_by_brakey(@assistit.brakey)
      comptesImpostos = Compte.where("ctcte LIKE '?%'",
                                     brain.braimp.to_i)
      comptesPagaments = Compte.where("ctcte LIKE '?%'",
                                      brain.brapag.to_i)
    end

    render :partial => 'assistits/new',
           :locals => {:frmLabels => @frmLabels,
                       :opckey => @opckey.to_s,
                       :comptesImpostos => comptesImpostos,
                       :comptesPagaments => comptesPagaments}

  end

  def edit
    mnusec = Menudet.find(params[:consultaId]).mnusec
    assistit = Menudet.find(mnusec)
    frmLabels = Menulit.getFormLabels(assistit.id)

    grupOrigen = Brain.grupOri(assistit.id)
    comptesOrigen = Compte.select('ctcte, ctdesc')
                          .where("ctcte LIKE '?%'", grupOrigen.to_i)
    grups_condition = buscarGrupComptable(assistit.id)
    comptesDesti = Compte.where(grups_condition)

    histMov = Historial.find(params[:id])
    histGens = histMov.histgens

    if assistit.opcfrm == 'frm_p3_modi'
      brain = Brain.find_by_brakey(assistit.brakey)
      comptesImpostos = Compte.where("ctcte LIKE '?%'",
                                     brain.braimp.to_i)
      comptesPagaments = Compte.where("ctcte LIKE '?%'",
                                      brain.brapag.to_i)

      histImps = histMov.histimps
      histPags = histMov.histpags
    end

    render :partial => 'assistits/edit',
           :locals => {:frmLabels => frmLabels,
                       :frmName => assistit.opcfrm,
                       :frmId => assistit.id,
                       :histMov => histMov,
                       :histGens => histGens,
                       :histImps => histImps,
                       :histPags => histPags,
                       :comptesOrigen => comptesOrigen,
                       :comptesDesti => comptesDesti,
                       :comptesImpostos => comptesImpostos,
                       :comptesPagaments => comptesPagaments}
  end

  def getCodiCompte
    opckey = params[:opckey]
    ctcte = params[:ctcte]
    grup_comptable = Brain.grupOri(opckey)

    codi = Compte.completarCodi(grup_comptable, ctcte)

    @compte = Compte.select('ctcte, ctdesc')
                    .where('ctcte = ?', codi)
    logger.debug @compte.inspect

    if @compte.present?
      render :json => @compte.first.to_json
    else
      render :text => 'Codi incorrecte', :status => 500
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
    
      @historial = Historial.buscarFactura(numdoc,ctcte,opckey)

      if @historial.present?
        render :partial => 'factura_duplicada'
      else
        render :text => ''
      end
    end

  end

  def getAssentament
    nrow = params[:nrows]
    opckey = params[:opckey].to_i

    assistit = Menudet.find(opckey)

    grups_condition = buscarGrupComptable(opckey)
    comptesDesti = Compte.where(grups_condition)
    
    render :partial => 'assistits/assentament',
           :locals  => {:nrow => nrow,
                        :comptesDesti => comptesDesti}
  end

  def getImpost
    nrow   = params[:nrows]
    opckey = params[:opckey].to_i

    assistit = Menudet.find(opckey)
    brain    = Brain.find_by_brakey(assistit.brakey)

    grupimpostos    = brain.braimp.to_i
    comptesImpostos = Compte.where("ctcte LIKE '?%'",
                                   grupimpostos)
    
    render :partial => 'assistits/impost',
           :locals  => {:nrow => nrow,
                        :comptesImpostos => comptesImpostos}
  end

  def getPagament
    nrow = params[:nrows]
    opckey = params[:opckey].to_i

    assistit = Menudet.find(opckey)

    brain = Brain.find_by_brakey(assistit.brakey)
    gruppagaments = brain.brapag.to_i
    comptesPagaments = Compte.where("ctcte LIKE '?%'",
                                      gruppagaments)
    
    render :partial => 'assistits/pagament',
           :locals  => {:nrow => nrow,
                        :comptesPagaments => comptesPagaments}
  end

  def newConcepte
    mnukey = params[:mnukey]
    brakey = Menudet.find(mnukey).brakey
    subgrup = Brain.find_by_brakey(brakey).brades

    render :partial => 'assistits/newconcepte',
           :locals  => {:subgrup => subgrup}
  end
end
