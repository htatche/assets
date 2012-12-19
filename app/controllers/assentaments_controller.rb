class AssentamentsController < ApplicationController
  
  respond_to :html, :json

  def show
    @moviments = Moviment.all
    render :json => @moviments
  end

  def new
    #Creem un moviment (apunt)

    @apunt = Moviment.new
  end

  def fillCtcteInput
    @input = Compte.autoCompleteCtcte(params[:numCompte])
    @compte = Compte.find_by_ctcte(@input)
   
    respond_with do |format|
      format.html do
        render :json => {:ctcte => @compte.ctcte, :ctdesc => @compte.ctdesc }
      end
    end
  end

# NO SUTILITZA
## NEW CODE

  def validarCompte
    @ctcte = params[:numCompte]
    @empresa = Empresa.where(:mpKey => empKey).first

    @retorn = {"err" => 0,
               "errmsg" => "",
               "ctcte" => "",
               "ctdesc" => ""
              }

    if not Compte.where(:ctcte > numCompte).empty? then
      # El compte ja existeix
      # -> Pintem de verd el cuadre
      @retorn["err"] = 0
      @retorn["ctdesc"] = Compte.where(:ctcte > numCompte).ctdesc
    else
      # El compte no existeix

      # Verifiquem si el format es correcte
      if (numCompte =~ /^[0-9]+[.][0-9]+$/) and numCompte.length < @empresa.emploc then
        if @parts_numCompte = numCompte.split(".") then
          if Pgc.where(:pgccte => @parts_numCompte[0]).empty? then
            @retorn["err"] = 2
            @retorn["errmsg"] = "Compte erroni"
          else
            # El format es correcte i el prefix PGC també, podem formatejar el numero

            # Omplenem amb els zeros que faltin
            @tamany_numCompte = @parts_numCompte[0].length + @parts_numCompte[1].length
            @restant = @empresa.emploc - @tamany_numCompte

            if @tamany_numCompte < @empresa.emploc then
                @compte = @parts_numCompte[0] + "0" * @restant + @parts_numCompte[1]
            end

            # Un cop el tenim formatejat correctament, mirem si existeix o no
            if Compte.where(:ctcte => @compte).empty? then
              @retorn["err"] = 1
              @retorn["errmsg"] = "Nou compte"
            else
              @retorn["err"] = 0
              @retorn["ctdesc"] = Compte.where(:ctcte > @compte).ctdesc
            end

          end
        end
      elsif ctcte[0, @empresa.emppgc]  
        # Aqui cal posar un else if abans, on es chequeji que no hagi posat el compte
        # en format normal 70000010 pero que el compte sigui nou i no estigui a la taula
        

        

        @response = "Aquest compte es erroni !"
      end
    end
  end

end
