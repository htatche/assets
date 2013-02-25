class AssentamentsController < ApplicationController
  
  respond_to :html, :json

  def new
    newNumass = Moviment.getNewNumass

    render :partial => 'assentaments/new',
           :locals => {:newNumAss => newNumass}

  end

  def create
    apunts = JSON.parse(params[:apunts])
    busca = Brain.buscar_brain(apunts)
    Moviment.comptabilitzar(apunts)
    Historial.crear_desde_assentament(apunts, busca)
  end

  def formatejarCompte
    @input = Compte.formatejar_compte(params[:numCompte])
    @compte = Compte.find_by_ctcte(@input)

    render :json => {:ctcte => @compte.ctcte, :ctdesc => @compte.ctdesc }
  end


end
