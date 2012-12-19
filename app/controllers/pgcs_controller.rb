class PgcsController < ApplicationController

  respond_to :html, :json

  def index
    # Temporal solution until we code empresa module
    @empresa = Empresa.first

    respond_with do |format|
      format.html do
        render :partial => 'index', :format => :html
      end
    end
  end

  def new
    @grup = Pgc.new
    @subgrup = true if params[:id] == 'subgrup'

    respond_with do |format|
      format.html do
        render :partial => 'form', :format => :html
      end
    end
  end

  def edit
    @grup = Pgc.find(params[:id])
    @subgrup = true unless @grup.parent_id.nil?

    respond_with do |format|
      format.html do
        render :partial => 'form', :format => :html
      end
    end
  end

  def delete
    @grup = Pgc.find(params[:id])

    respond_with do |format|
      format.html do
        render :partial => 'delete', :format => :html
      end
    end
  end
  def create

    # Use ancestry to create new child for subgrups
    if params.has_key?(:parent_id)
      @grup = Pgc.find(params[:parent_id]).children.new(params[:pgc])
    else
      @grup = Pgc.new(params[:pgc])
    end

    if @grup.save
      respond_with do |format|
        format.html do
          render :json => @grup.to_json
        end
      end
    else
      respond_with do |format|
        format.html do
          render :json => @grup.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  def update
    @grup = Pgc.find(params[:id])
    
    if @grup.update_attributes(params[:pgc])
      respond_with do |format|
        format.html do
          render :json => @grup.to_json
        end
      end
    else
      respond_with do |format|
        format.html do
          render :json => @grup.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @grup = Pgc.find(params[:id])

    if @grup.destroy
      respond_with do |format|
        format.html do
          render :json => @grup
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

  # Conectat al jqxTree del PGC, retorna un JSON
  def tree
    # No utilitzem directament un Pgc.select("id, parent_id, pgcdes")
    # perque com que fem servir el gem Ancestry, si demanem el parent_id
    # a través del ActiveRecord ens retorna NULL. Cal fer aquest pas:
    @categories = Pgc.where("pgccla = 1").all
    @categories_list = @categories.map do |c| {
      :id => c.id, :parent_id => c.parent_id, :pgcdes => "<span name='grup'>" + c.pgccte.to_s + " - " + c.pgcdes + "</span>" }
    end

    @comptes = Compte.all
    @comptes_list = @comptes.map do |c| {
      :id => c.ctcte, :parent_id => c.pgc_id, :pgcdes => "<span name='compte'>" + c.ctcte.to_s + " - " + c.ctdesc + "</span>" }
    end

    # Unify both arrays for to consolidate the PGC tree
    @categories_list += @comptes_list

    render :json => @categories_list.to_json
  end

  # We obtain the category (Grup/Subgrup/Compte) of
  # selectem item in PGC jqxTree, and we decide 
  # to disable/enable the event buttons
  # 0 = Grup
  # 1 = Subgrup
  # 2 = Compte
  def getTreeItemCategory
    @id = params[:id] 

    if Pgc.exists?(@id) then
      @item = Pgc.find(@id)
      
      if @item.parent_id == nil then
        @category = 0

      else
        @category = 1

        if @item.children.empty? then
          @childCategories = false
        else
          @childCategories = true
        end

        if Compte.where(:pgc_id => @item.id).empty?
          @childComptes = false
        else
          @childComptes = true
        end
      end
    else
      @category = 2
    end

    respond_to do |format|
      format.json  { render :json => {:category => @category,
                                      :childCategories => @childCategories,
                                      :childComptes => @childComptes }}
    end
  end

end
