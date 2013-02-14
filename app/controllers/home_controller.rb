class HomeController < ApplicationController
  respond_to :html

  def index 
    @menuOptions = Menu.all
  end
end
