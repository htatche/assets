class HistorialsController < ApplicationController
  
  def consulta
    @mnukey = params[:mnukey]
    @mnulabel = Menu.find(@mnukey).mnutit

    @consultes = Menudet.where('mnukey = ? AND opcmodul = ?',
                               @mnukey,
                               'consulta')
    @grups_condition = buscarGrupComptable(@mnukey)
    logger.debug @grups_condition
    exit
    @comptes = Compte.where(@grups_condition)

    render :partial => 'historials/consulta'
  end

  def search
    @moviments = Historial.select('datdoc, numdoc')

    respond_to do |format|
      format.json { render :json => @moviments }
    end

  end

end
