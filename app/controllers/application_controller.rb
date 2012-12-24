class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :menuOptions
  prepend_before_filter :load_schema
  before_filter :authenticate_user

  def menuOptions
    Menu.all
  end

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
    #Apartment::Database.switch('muesliinc')
  end

end
