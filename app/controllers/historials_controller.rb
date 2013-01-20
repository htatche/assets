class HistorialsController < ApplicationController
  
  def consulta
    @mnukey = params[:mnukey]
    @mnulabel = Menu.find(@mnukey).mnutit

    @consultes = Menudet.where('mnukey = ? AND opcmodul = ?',
                               @mnukey,
                               'consulta')
                        .order('id ASC')

    @brakey = Menudet.find_by_mnukey(@mnukey).brakey

    @grup = Brain.find_by_brakey(@brakey)
    @grup = @grup.braori.nil? ? '' : @grup.braori

    @comptes = Compte.where("ctcte LIKE '?%'",
                            @grup.to_i)

    render :partial => 'historials/consulta'
  end

  def getGridTitles
    opckey = params[:opckey]
    labels = Menulit.getFormLabels(opckey)

    render :json => labels
  end

  def search

    cond = {}

    cond[:brakey] = Menudet.find(params[:tipusConsulta]).brakey
    cond[:ctkey] = params[:client] unless params[:client] = 'all'

    case params[:dateMode]
      when 'period'
        dateFrom = Date.strptime(params[:dateFrom], '%d/%m/%Y')
        dateTo = Date.strptime(params[:dateTo], '%d/%m/%Y')
      when 'predefined'
        dateFrom = case params[:date]
          when 'last_month'
            1.month.ago
          when 'last_3_months'
            3.months.ago
          when 'last_6_months'
            6.months.ago
          when 'last_year'
            1.year.ago
        end
        dateTo = Date.today
    end

    cond[:datsis] = dateFrom..dateTo

    @moviments = Historial.where(cond)

    @moviments = @moviments.map do |i| { 
      :datdoc => i.datdoc,
      :numdoc => i.numdoc,
      :ctcte => i.compte.ctcte,
      :ctdesc => i.compte.ctdesc,
      :datsis => i.datsis,
      :impdoc => i.impdoc,
      :comdoc => i.comdoc
    } end

    respond_to do |format|
      format.json { render :json => @moviments }
    end

  end

end
