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

  def show
    empresa = Empresa.find(params[:id])

    # Creem el esquema si es el primer acces
    if @current_user.is_admin?(empresa.id) && !empresa.schema
      name = empresa.create_schema
    end

    if @current_user.is_member?(empresa.id)
      load_schema
    end 

    redirect_to '/home'
  end

  def create

    res = {}
    new_password = Digest::SHA1.hexdigest(
      [params[:email], Time.now, rand].join
    )[0,6]

    begin 
      Empresa.transaction do
        # Crea la empresa
        empresa = Empresa.new({
          :empnom => params[:empresa_nom],
          :expiracio_contracte => params[:expiracio_contracte]
        })
        empresa.save!

        # Crea un usuari si no existeix
        if (users = User.where('email LIKE ?', params[:email])).any?
          user = users.first
          res = {:data => 'existing_user', :email => params[:email]}
        else
          user = User.new({
            :nom => params[:nom],
            :cognoms => params[:cognoms],
            :email => params[:email],
            :password => new_password,
            :password_confirmation => new_password
          })
          user.save!

          res = {:data => 'new_user',
                 :email => params[:email],
                 :password => new_password}
        end

        # Associa l'usuari com a administrador de l'empresa
        hab = Habilitacio.new({
          :user_id => user.id,
          :empresa_id => empresa.id,
          :level => 0
        }).save!
      end

      render :json => res
    rescue ActiveRecord::RecordInvalid
      render :json => {:errors => $!.to_s}
    end
  end

  def admin
  end

end
