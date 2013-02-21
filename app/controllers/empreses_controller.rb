class EmpresesController < ApplicationController
  respond_to :html, :json
  skip_before_filter :authenticate_user, :only => [:create, :update]
  skip_before_filter :load_schema, :only => [:show]
  before_filter :check_api_key, :only => :create

  def check_api_key
    if params[:api_key] != ApplicationSettings.config['api_key']
      render :json => {:error => 'No he pogut crear la empresa'},
             :status => :unprocessable_entity
    end
  end

  def home
    if session[:schema]
      redirect_to "/empreses/#{@current_user.empresas.first.id}"
    else
      if @current_user.empresas.count == 0
        render 'contactar_empresa'
      elsif @current_user.empresas.count == 1
        redirect_to "/empreses/#{@current_user.empresas.first.id}"
      elsif @current_user.empresas.count > 1
        render :partial => 'choose'
      end
    end
  end

  def show
    empresa = Empresa.find(params[:id])

    # Creem el esquema si es el primer acces
    if @current_user.is_admin?(empresa.id) && !empresa.schema
      schema = empresa.create_schema
      Empresa.seed_schema(schema)
    end
  
    # Li demanem de parametritzar la empres si encara no ho ha fet
    if @current_user.is_admin?(empresa.id) && Parametre.all.empty?
      session[:schema] = empresa.schema
      redirect_to :controller => :parametres, :action => :new
    end

    if @current_user.is_member?(empresa.id)
      session[:schema] = empresa.schema
      load_schema
    end 

    @options = Menu.all
  end

  def create

    res = {}
    new_password = Digest::SHA1.hexdigest(
      [params[:email], Time.now, rand].join
    )[0,6]
    
    user = nil # La creem aqui per utilitzarla despres del block

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
      
          UserMailer.signup_email(user).deliver
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
