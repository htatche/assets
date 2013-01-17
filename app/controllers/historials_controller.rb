class HistorialsController < ApplicationController
  
  # Consulta de un historial (un brakey)
  def consulta
    @mnukey = params[:mnukey]
    @mnulabel = Menu.find(@mnukey).mnutit
    @comptes = Compte.all


    
  end

  def search

  end

end
