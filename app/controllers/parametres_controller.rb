class ParametresController < ApplicationController
  skip_before_filter :load_schema, :only => [:new]

  def new
    @parametre = Parametre.new
  end

  def create
    @parametre = Parametre.new(params[:parametre])

    if @parametre.save
      redirect_to "/empreses/#{@current_empresa.id}"
    else
      flash[:error] = 'Alguns camps son incorrectes:'
      render :new
    end
  end

end
