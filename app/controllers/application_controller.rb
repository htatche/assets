class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :menuOptions
  prepend_before_filter :load_schema
  before_filter :authenticate_user

protected 

  def authenticate_user
    unless session[:user_id]
      redirect_to(:controller => 'sessions', :action => 'login')
      return false
    else
      # set current user object to @current_user object variable
      @current_user = User.find session[:user_id] 
      return true
    end
  end

  def save_login_state
    if session[:user_id]
      redirect_to(:controller => 'home', :action => 'index')
      return false
    else
      return true
    end
  end

  def load_schema
#Apartment::Database.switch('brossa')
  end

public

  def buscarGrupComptable(opckey)
    @grups_condition = ''
    @grup_comptable = Menudet.find(opckey)

    if @grup_comptable.present?
      @brain = Brain.where('brakey = ?', @grup_comptable.brakey)
    end

    if @brain.present?
      @brain = @brain.first

      @grups_condition = "ctcte LIKE '#{@brain.brades}%' "
      @braindet = Braindet.where('brakey = ?', @grup_comptable.brakey)
                          .order('brdlin')

      @braindet.each{ |i| 
        @grups_condition += ' OR ctcte LIKE "' + i.brddes + '%"' if i.brddes
      }
    end

    @grups_condition
  end

  def getComptes
    opckey = params[:mnukey]

    grup_comptable = Brain.grupOri(opckey)
    @comptes = Compte.select('ctcte, ctdesc')
                     .where("ctcte LIKE '?%'",
                            grup_comptable.to_i)

    if @comptes.present?
      @json = []
      @comptes.each{ |i|
        html = i.ctcte.to_s + ' - ' + i.ctdesc
        @json << {html: html, title: i.ctcte.to_s}  
      }

      render :json => @json
    else
      render :json => {}
    end
  end


end
