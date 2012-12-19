class ComptesController < ApplicationController
  respond_to :html, :json

  # La guardem perque pot ser util, no la utilitzem
  def show
    Compte.all.each { |x| x.update_attribute('pgc_id', '1' + x.pgc_id.to_s[1,3]) }
  end

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

    @compte = Compte.new(params[:compte])

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

end
