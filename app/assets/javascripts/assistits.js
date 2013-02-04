function Assistit(tab, frmView) {
  var _this      = this;
      moduleName = 'assistit',
      /* El div del dialog de jquery-ui es cree fora */
      context    = (frmView === 'new') ? tab.htmlDiv : $('#editDialog'),
      htmlDiv    = context.find('div.' + moduleName),
      assistitId = htmlDiv.attr('id'),
      tCtdesc    = htmlDiv.find('input[name=ctdesc]'),
      tNumDoc    = htmlDiv.find('input[name=numdoc]'),
      tCtekey    = htmlDiv.find('input[name=ctekey]');

  _this.htmlDiv = htmlDiv;

  _this.getFacturaDuplicada = function(numdoc, ctekey, opckey) {
    if (tNumDoc.val() && tCtekey.val()) {
      _this.htmlDiv.find('#factura-duplicada').remove();
      $.get('/assistits/getFacturaDuplicada',
            { numdoc: numdoc,
              ctcte: ctekey,
              opckey: opckey
            },
        function(data) {
          if (data) {
            var dialog = data;
            var errmsg;
            
            errmsg = '<div id="factura-duplicada" class="input-validation-error">';
            errmsg += 'Aquesta factura ja existeix, <a href="#"> Mostrar </a>';
            errmsg += '</div>';
            
            _this.htmlDiv.find('#factura-duplicada').remove();
            _this.htmlDiv.find('input[name=numdoc]').after(errmsg);
            _this.htmlDiv.find('#factura-duplicada').fadeIn('fast');
            _this.htmlDiv.find('#factura-duplicada a').click(function() {
              $(dialog).dialog({
                autoOpen: false,
                height: "auto",
                width: "auto",
                autoResize:true,
                resizable: false,
                modal: true,
                close: function() {
                }
              }).dialog('open');
            });
          } else {
            _this.htmlDiv.find('#factura-duplicada').remove();
          }
        });
    }
  };

  _this.getComptes = function() {
    $.get('/getComptes',
          {mnukey: assistitId},
          function(data) {
            combobox = _this.htmlDiv.find('div.ctcte-combobox').jqxComboBox({
              source: data,
              width: '230px',
              height: '25px',
              dropDownWidth: '300px',
              theme: theme });

            combobox.find('input').attr({name: 'ctekey'});
            combobox.find('input').css({padding: '2px'});

            tNumDoc = _this.htmlDiv.find('input[name=numdoc]');
            tCtekey = _this.htmlDiv.find('input[name=ctekey]');
            _this.setBindings();
            _this.setTabindexes();
    });
  };

  _this.getCodiCompte = function(ctcte, errtpl, input) {
    _this.htmlDiv.find('.error-compte').remove();

    $.getJSON('/assistits/getCodiCompte',
      {opckey: assistitId,
       ctcte: ctcte},
      function(data) {
        tCtekey.val(data.ctcte);
        tCtdesc.val(data.ctdesc);
    }).error(function() {
        var template = _.template($(errtpl).html()),
            tpldata  = {
              ctcte: tCtekey.val(),
              ctdesc: tCtdesc.val()
            };

        _this.htmlDiv.find(input).after(
          template(tpldata)
        );

        _this.htmlDiv.find('.error-compte').fadeIn('fast');
      })
      .complete(function() {
        _this.getFacturaDuplicada(tNumDoc.val(),
                                  tCtekey.val(),
                                  assistitId);
      });
  };

  _this.reload = function() {
    tab.getContent('/assistit/' + assistitId, 'assistit');
  };

  _this.showErrorsTemplate = function(data) {
    _.templateSettings.variable = "rc";

     var errors   = jQuery.parseJSON(data.responseText),
         tpldata  = {errors: errors},
         template = _.template(
          $('script.tpl-assistit-errors').html() 
         );
     
     _this.htmlDiv
          .find('form div.errors')
          .html(template(tpldata))
          .addClass('ui-state-error ui-corner-all')
          .effect('highlight', {color: '#FFAAAA'}, 500);

     _this.htmlDiv
          .find('form div.errors')
          .fadeIn('fast');
  }

  _this.create = function() {

    var reqType = 'POST',
        reqUrl  = '/assistits';

    $.ajax({
      url:  reqUrl,
      type: reqType,
      data: _this.htmlDiv.find('form').serialize(),

      success: function(data) {  _this.reload(); },
      error:   function(data) { _this.showErrorsTemplate(data); }
    });

  };

  _this.update = function() {

    var reqType = 'PUT',
        id      = _this.htmlDiv.find('input[name="id"]').val(),
        reqUrl  = '/assistits/'+id;

    $.ajax({
      url:  reqUrl,
      type: reqType,
      data: _this.htmlDiv.find('form').serialize(),

      success: function(data) {
                 tab.consulta.editDialog.dialog('close');
                 tab.consulta.search();
               },
      error:   function(data) { _this.showErrorsTemplate(data); }
    });

  };

  _this.submit = function() {

    _this.htmlDiv.find('form div.errors')
           .html('')
           .hide();

    if (frmView === 'new') {
      _this.create();
    } else {
      _this.update();
    }
    
  };

  _this.setTabindexes = function() {
    _this.htmlDiv.find('form input,select').each(function(index) {
      $(this).attr('tabindex', index);
    });
  };

  _this.setBindings = function() {

    tNumDoc.blur(function() {
        items = _this.getFacturaDuplicada(tNumDoc.val(),
                                          tCtekey.val(),
                                          assistitId);
    });

    $.each([tCtekey, tCtdesc], function() {
      this.blur(function() {
        _this.htmlDiv.find('.error-compte').remove();

        if (tCtekey.val() && tCtdesc.val()) {
          _this.getCodiCompte(tCtekey.val(),
                              'script.tpl-error-1',
                              'div.ctcte-combobox');
        } else if (tCtekey.val() && tCtdesc.val() === '') {
          _this.getCodiCompte(tCtekey.val(),
                              'script.tpl-error-2',
                              'input[name=ctdesc]');
        } else if (tCtekey.val() === '' && tCtdesc.val()) {
          _this.getCodiCompte(tCtekey.val(),
                              'script.tpl-error-3',
                              'div.ctcte-combobox');
        }
      });


    });

    _this.htmlDiv.find('input[name=comment]').blur(function() {
      fieldset = _this.htmlDiv.find('fieldset#assentaments');
      var nrows = _this.assentament.nrows(fieldset);

      if (nrows == 1) {
        fieldset.find('input.import')
          .val(_this.htmlDiv.find('fieldset.main input[name=import]').val());
        fieldset.find('input.comment')
          .val(_this.htmlDiv.find('fieldset.main input[name=comment]').val());
      }
    });

    _this.htmlDiv.find('div.ctcte-combobox').bind('select', function() {
        _this.getCodiCompte(tCtekey.val());
    });

    _this.htmlDiv.find('form').submit(function() {
      _this.submit();
      
      /* Cancel primary submit action (.preventDefault()) */
      return false;
    });
  };

  _this.fire = function() {
    _this.htmlDiv.jqxExpander({ showArrow: false, toggleMode: 'none' });
    inputToNumeric(_this.htmlDiv.find('fieldset.main div.numeric'),
                   _this.htmlDiv.find('fieldset.main input.import'),
                   '230px',
                   _this.htmlDiv.find('fieldset.main input.import').attr('height'));
    _this.htmlDiv.find('div.numeric').find('input').attr({tabindex: '5',
                                               name: 'import'});

    _this.assentament = new Assentament(tab, _this.htmlDiv);
    _this.getComptes();
  };
  
}

function Assentament(tab, parentHtmlDiv) {
  var _this = this;
  assistitId = parentHtmlDiv.attr('id');

  _this.initialize = function() {
    _this.bindings();
  };

  _this.bindKeydown = function(fieldset) {
    fieldset.find('input:last').unbind('keydown.newrow');
    fieldset.find('input:last').on('keydown.newrow', function(e) {
      if(e.which === 13) {
        fieldset = $(this).parents('fieldset');
        _this.getRow(fieldset);
        $(this).unbind('keydown');

        return false;
      }
    });
  };

  _this.bindings = function() {
  
    parentHtmlDiv.find('fieldset:not(.main)').each(function() {
      _this.bindDestoyIcon($(this));
    });

    parentHtmlDiv.find('fieldset:not(.main)').each(function() {
      $(this).find('div.numeric').each(function() {
        inputToNumeric($(this),
                       $(this).prev('input.import'),
                       '100px',
                       '28px');
      });
    });

    parentHtmlDiv.find('fieldset:not(.main)').each(function() {
      _this.bindKeydown($(this));
    });

    parentHtmlDiv.find('div#newConcepte').click(function() {
      var tag = jQuery('<div/>', {
                  id: 'newconcepteDialog',
                  class: 'newconcepteDialog',
                  title: 'Crear un nou concepte' });
      $.ajax({
        url: '/assistits/newConcepte/'+assistitId,
        success: function(data) {

          _this.editDialog = tag.html(data).dialog({
            autoOpen: false,
            height: "auto",
            width: "auto",
            autoResize:true,
            resizable: false,
            modal: true,
            close: function() {
              $(this).remove();
              delete tab.pgc;
            },
            open: function( event, ui ) {
              var subgrup = tag.find('div.pgcs').attr('id');

              tab.pgc = new Pgc(tab, subgrup);
              tab.pgc.fire();
            }
          }).dialog('open');
        }
      });
      
    });
  };

  _this.nrows = function(fieldset) {
    return fieldset.find('table>tbody>tr').length;
  };

  _this.setTabindexes = function() {
    parentHtmlDiv.find('form input,select').each(function(index) {
      $(this).attr('tabindex', index);
    });
  };

  _this.bindDestoyIcon = function(fieldset) {
    fieldset.find('tr:last td.destroy span')
      .click(function() {
        if (fieldset.find('table tbody tr').length > 1) {
          $(this).parents('tr').remove();
          _this.bindKeydown(fieldset);
          _this.setTabindexes();
        }
      });
  };

  _this.getRow = function(fieldset) {
    id = fieldset.attr('id');

    if (id == 'assentaments') {
      action = 'getAssentament';
    }
    else if (id == 'impostos') {
      action = 'getImpost';
    }
    else if (id == 'pagaments') {
      action ='getPagament';
    }

    $.get(
      '/assistits/' + action,
      {opckey: assistitId,
       nrows: _this.nrows(fieldset)},
      function(data) {
        _this.setRow(fieldset, data);
      }
    );
  };

  _this.setRow = function(fieldset, data) {
    $(data).appendTo(fieldset.find('table>tbody'));

    inputToNumeric(fieldset.find('input.import:last').next('div.numeric'),
                   fieldset.find('input.import:last'),
                   '100px',
                   '28px');
    fieldset.find('select:last').focus();
    _this.bindDestoyIcon(fieldset);
    _this.bindKeydown(fieldset);
    _this.setTabindexes();
  };

  _this.initialize();
}
