class SessionsController < ApplicationController
  skip_before_filter :authenticate_user, :only => [:login, :login_attempt]
  before_filter :save_login_state, :only => [:login, :login_attempt]

 def login
 end

 def login_attempt
   authorized_user = User.authenticate(params[:username_or_email],params[:login_password])
   if authorized_user
     session[:user_id] = authorized_user.id
     redirect_to('/home')
   else
     flash[:notice] = "Usuari o contrasenya invalids"
     flash[:color]= "invalid"
     render "login"  
   end
 end

 def logout
   session[:user_id] = nil
   redirect_to :action => 'login'
 end

  def home
  end

  def profile
  end

  def setting
  end

end
