class AssentamentsController < ApplicationController
  
  respond_to :html, :json

  def new
    newNumass = Moviment.getNewNumass

    render :partial => 'assentaments/new',
           :locals => {:newNumAss => newNumass}

  end

  def create
    logger.debug params[:cttext].inspect

    params[:apunts].each { |apunt|
      logger.debug apunt.inspect
    }
  end

  def formatejarCompte
    @input = Compte.formatejarCompte(@current_empresa.emploc,
                                     params[:numCompte])
    @compte = Compte.find_by_ctcte(@input)
   
    render :json => {:ctcte => @compte.ctcte, :ctdesc => @compte.ctdesc }
  end


end
