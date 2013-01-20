class HistorialsController < ApplicationController
  
  def consulta
    @mnukey = params[:mnukey]
    @mnulabel = Menu.find(@mnukey).mnutit

    @consultes = Menudet.where('mnukey = ? AND opcmodul = ?',
                               @mnukey,
                               'consulta')
    #grup_comptable = Brain.grupOri(@mnukey)

    @brakey = Menudet.find_by_mnukey(@mnukey).brakey

    @grup = Brain.find_by_brakey(@brakey)
    @grup = @grup.braori.nil? ? '' : @grup.braori

    @comptes = Compte.select('ctcte, ctdesc')
                     .where("ctcte LIKE '?%'",
                            @grup.to_i)

    render :partial => 'historials/consulta'
  end

  def search
    @moviments = Historial.select('datdoc, numdoc')

    respond_to do |format|
      format.json { render :json => @moviments }
    end

  end

end
