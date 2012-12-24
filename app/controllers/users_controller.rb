class UsersController < ApplicationController
  skip_before_filter :authenticate_user, :only => [:new, :create]
  before_filter :save_login_state, :only => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'T\'has inscrit correctament'
      flash[:color] = 'valid'
    else
      flash[:notice] = 'Alguns camps son incorrectes'
      flash[:color] = 'invalid'
    end

    render 'new'
  end
      

end