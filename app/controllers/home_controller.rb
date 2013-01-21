class HomeController < ApplicationController
  respond_to :html

  def index 
    @menuOptions = Menu.all
  end

  def home
    render :partial => 'home/home'
  end

end
