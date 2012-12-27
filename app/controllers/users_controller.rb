class UsersController < ApplicationController
  skip_before_filter :authenticate_user, :only => [:new, :create, :confirm]
  before_filter :save_login_state, :only => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.signup_email(@user).deliver
      render :check_your_mail
    else
      flash[:error] = 'Alguns camps son incorrectes:'
      render :new
    end

  end

  def confirm
    user = User.find(params[:id])

    if user.match_confirmation_code(params[:code])
      user.save!

      flash[:notice] = 'Felicitats, has validat el teu compte !'
      redirect_to '/login'
    else
      redirect_to '/home'
    end

  end

  def validate_empresa
  end

end
