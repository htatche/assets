class EmpresesController < ApplicationController
  respond_to :html, :json
  skip_before_filter :authenticate_user, :only => [:create, :update]
  before_filter :check_api_key, :only => :create

  def home
  end

  def check_api_key
    if params[:api_key] != ApplicationSettings.config['api_key']
      render :json => {:error => 'No he pogut crear la empresa'},
             :status => :unprocessable_entity
    end
  end

  def create
    password = Digest::SHA1.hexdigest(
      [params[:email], Time.now, rand].join
    )[0,6]

    begin 
      Empresa.transaction do
        empresa = Empresa.new ({
          :empnom => params[:empresa_nom],
          :expiracio_contracte => params[:expiracio_contracte]
        })
        user = User.new ({
          :nom => params[:nom],
          :cognoms => params[:cognoms],
          :email => params[:email],
          :password => password,
          :password_confirmation => password
        })

        if empresa.save! && user.save!
          hab = Habilitacio.new ({
            :user_id => user.id,
            :empresa_id => empresa.id,
            :level => 0
          })
          hab.save!
        end
      end

      render :json => {:email => params[:email], :password => password}
    rescue ActiveRecord::RecordInvalid
      render :json => {:errors => $!.to_s}
    end
  end

  def admin
  end

end
