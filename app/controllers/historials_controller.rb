class HistorialsController < ApplicationController
  
  def consulta
    @mnukey = params[:mnukey]
    @mnulabel = Menu.find(@mnukey).mnutit

    @consultes = Menudet.where('mnukey = ? AND opcmodul = ?',
                               @mnukey,
                               'consulta')

    @brakey = Menudet.find_by_mnukey(@mnukey).brakey

    @grup = Brain.find_by_brakey(@brakey)
    @grup = @grup.braori.nil? ? '' : @grup.braori

    @comptes = Compte.select('ctcte, ctdesc')
                     .where("ctcte LIKE '?%'",
                            @grup.to_i)

    render :partial => 'historials/consulta'
  end

  def search
    @moviments = Historial.all
    @moviments = @moviments.map do |i| { 
      :datdoc => i.datdoc,
      :numdoc => i.numdoc,
      :ctcte => i.compte.ctcte,
      :ctdesc => i.compte.ctdesc,
      :datsis => i.datsis,
      :impdoc => i.impdoc,
      :comdoc => i.comdoc
    } end

    respond_to do |format|
      format.json { render :json => @moviments }
    end

  end

end
