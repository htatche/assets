class ComptabilitatController < ApplicationController
  def show
    @mnukey = params[:option]
    @menuOptions = Menudet.where('mnukey = ?',
                                 @mnukey)

    if @menuOptions.present? 
      render :partial => 'show',
             :locals => {:menuOptions => @menuOptions}
    end
 
  end

end
