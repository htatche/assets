class MovimentsController < ApplicationController
  respond_to :html, :xml, :json

  def search

  end

  def grid
    @moviments = Moviment.all
    render :json => @moviments
  end

  def show
  end

  def buscarGrupComptable
    @menudet = Menudet.find(params[:option])

    if @menudet.present?
      @grupComptableKey = @menudet.brakey
    else
      "404"
    end

    @brain = Brain.where('brakey = ?', @grupComptable)
    
    if @brain.present?
      @grupComptable = @brain.braori.nil? ? "" : @brain.braori
      @grupComptableDesti = @brain.braori.nil? ? "" : @brain.braori

      @braindet = Braindet.where('brakey = ?', @grupComptableKey).order('brdlin ASC')

      @comptesFilter = []
      @braindet.each {|x| 
        @comptesFilter.push(x)
      }
    else
      "Error amb el BRAIN"
    end
  end

  
end
