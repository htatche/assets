class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :menuOptions

  def menuOptions
    Menu.all
  end
end
