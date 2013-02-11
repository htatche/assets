class ParametresController < ApplicationController
  respond_to :html, :json
  skip_before_filter :load_schema, :only => [:new]

  def new
    @parametre = Parametre.new
    @pgctipus = Pgctipus.all.collect {|p| [ p.descripcio, p.id ] }
  end

  def create
    @parametre = Parametre.new(params[:parametre])
    @pgctipus = Pgctipus.all.collect {|p| [ p.descripcio, p.id ] }

    if @parametre.save
      redirect_to "/empreses/#{@current_empresa.id}"
    else
      flash[:error] = 'Siusplau verifica els seguents errors: '
      render :new
    end
  end

end
