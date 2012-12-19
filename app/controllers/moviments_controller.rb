class MovimentsController < ApplicationController
  respond_to :html, :xml, :json

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

  #def new
  #  @option = params[:option]
  #  @frmLabels = Menulit.getFormLabels(@option)
#
#    respond_with do |format|
#      format.html do
#        render :partial => 'frm_new_p1', :locals => {:frmLabels => @frmLabels}
#      end
#    end
#  end
  
  def create

    @apunt = Moviment.new(params[:moviment])
    
    # Creem el compte si no existeix
    unless Compte.where(:numCompte => params[:numCompte]) then
      #Compte.generar_nou_compte(params[:numCompte], params[:descripcioCompte])
    end

    @apunt.set_num_compte = params[:numCompte]

    logger.debug @apunt.inspect
    
    if @apunt.save
      respond_with do |format|
        format.html do
          render :partial => "moviments/grid"
        end
      end
    else
      respond_with do |format|
        format.html do
          render :json => @apunt.errors, :status => :unprocessable_entity
        end
      end
    end
  end
end
