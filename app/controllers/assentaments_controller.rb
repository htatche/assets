class AssentamentsController < ApplicationController
  
  respond_to :html, :json

  def new
    newNumass = Moviment.getNewNumass

    render :partial => 'assentaments/new',
           :locals => {:newNumAss => newNumass}

  end

  def create
    busca = Brain.buscar_brain(params[:apunts])
    Moviment.comptabilitzar(params[:apunts])



    exit
  end

  def formatejarCompte
    @input = Compte.formatejar_compte(params[:numCompte])
    @compte = Compte.find_by_ctcte(@input)

    render :json => {:ctcte => @compte.ctcte, :ctdesc => @compte.ctdesc }
  end


end
