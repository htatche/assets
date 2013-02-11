class ComptesController < ApplicationController
  respond_to :html, :json

  def new
    @empresa = Empresa.first
    @compte = Compte.new

    respond_with do |format|
      format.html do
        render :partial => 'form', :format => :html
      end
    end
  end

  def edit
    @empresa = Empresa.first
    @compte = Compte.find_by_ctcte(params[:id])

    respond_with do |format|
      format.html do
        render :partial => 'form', :format => :html
      end
    end
  end

  def delete
    @compte = Compte.find_by_ctcte(params[:id])

    respond_with do |format|
      format.html do
        render :partial => 'delete', :format => :html
      end
    end
  end

  def create
    grup = Pgc.find(params[:compte][:pgc_id]).pgccte
    ctcte = params[:compte][:ctcte]

    full_ctcte = Compte.completarCodi(grup, ctcte)

    @compte = Compte.new(params[:compte])
    @compte.ctcte = full_ctcte

    if @compte.save
      respond_with do |format|
        format.html do
          render :json => @compte.to_json
        end
      end
    else
      respond_with do |format|
        format.html do
          render :json => @compte.errors, :status => :unprocessable_entity
        end
      end
    end

  end

  def update
    @compte = Compte.find_by_ctcte(params[:compte][:ctcte])
    
    if @compte.update_attributes(params[:compte])
      respond_with do |format|
        format.html do
          render :json => @compte.to_json
        end
      end
    else
      respond_with do |format|
        format.html do
          render :json => @compte.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @compte = Compte.find_by_ctcte(params[:id])

    if @compte.destroy 
      respond_with do |format|
        format.html do
          render :json => @compte
        end
      end
    else
      respond_with do |format|
        format.html do
          render :status => :unprocessable_entity
        end
      end
    end

  end

  def exists
    if Compte.exists?(params[:ctcte])
      render :json => {:exists => true }
    else
      render :json => {:exists => false }
    end
  end

end
