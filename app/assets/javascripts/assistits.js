function Assistit(tab, frmView) {
  var _this = this;
  var moduleName = 'assistit';

  if (frmView === 'new') {
    var htmlDiv = tab.htmlDiv.find('div.' + moduleName);
  } else {
    var htmlDiv = $('#editDialog').find('div.' + moduleName);
  }

  var tNumDoc,
      tCtekey,
      tCtdesc    = htmlDiv.find('input[name=ctdesc]'),
      assistitId = htmlDiv.attr('id');

  _this.getFacturaDuplicada = function(numdoc, ctekey, opckey) {
    if (tNumDoc.val() && tCtekey.val()) {
      htmlDiv.find('#factura-duplicada').remove();
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
            
            htmlDiv.find('#factura-duplicada').remove();
            htmlDiv.find('input[name=numdoc]').after(errmsg);
            htmlDiv.find('#factura-duplicada').fadeIn('fast');
            htmlDiv.find('#factura-duplicada a').click(function() {
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
            htmlDiv.find('#factura-duplicada').remove();
          }
        });
    }
  };

  _this.getComptes = function() {
    $.get('/getComptes',
          {opckey: assistitId},
          function(data) {
            combobox = htmlDiv.find('div.ctcte-combobox').jqxComboBox({
              source: data,
              width: '230px',
              height: '25px',
              dropDownWidth: '300px',
              theme: theme });

            combobox.find('input').attr({name: 'ctekey'});
            combobox.find('input').css({padding: '2px'});

            tNumDoc = htmlDiv.find('input[name=numdoc]');
            tCtekey = htmlDiv.find('input[name=ctekey]');
            _this.setBindings();
            _this.setTabindexes();
    });
  };

  _this.getCodiCompte = function(ctcte, errtpl, input) {
    htmlDiv.find('.error-compte').remove();

    $.getJSON('/assistits/getCodiCompte',
      {opckey: assistitId,
       ctcte: ctcte},
      function(data) {
        tCtekey.val(data.ctcte);
        tCtdesc.val(data.ctdesc);
    })
    .error(function() {
      var template = _.template(
        $(errtpl).html() 
      );

      var tpldata = {
        ctcte: tCtekey.val(),
        ctdesc: tCtdesc.val()
      };
      
      htmlDiv.find(input).after(
        template(tpldata)
      );

      htmlDiv.find('.error-compte').fadeIn('fast');
    })
    .complete(function() {
        _this.getFacturaDuplicada(tNumDoc.val(),
                                  tCtekey.val(),
                                  assistitId);
    });
  };

  _this.reload = function() {
    $.get('/assistit/' + assistitId, function (data) {
      tab.htmlDiv.find('.content').html(data);
      
      tab.loadModule(moduleName);
    });
  };

  _this.submit = function() {
    var dialog = htmlDiv.prev('ui-dialog'); ////

    htmlDiv.find('form div.errors')
           .html('')
           .hide();

    if (frmView === 'new') {
      reqType = 'POST';
      reqUrl = '/assistits';
    } else {
      reqType = 'PUT';
      id = htmlDiv.find('input[name="id"]').val();
      reqUrl = '/assistits/'+id;
    }

    $.ajax({
      url: reqUrl,
      type: reqType,
      data: htmlDiv.find('form').serialize(),

      success: function(data) {
        if (frmView === 'new') {
          _this.reload();
        } else {
          tab.consulta.editDialog.dialog('close');
          tab.consulta.search();
        }
      },

      error: function(data) {
        _.templateSettings.variable = "rc";

        var errors = jQuery.parseJSON(data.responseText);
        var template = _.template(
          $('script.tpl-assistit-errors').html() 
        );
        var tpldata = {errors: errors};
        
        htmlDiv.find('form div.errors')
          .html(template(tpldata))
          .addClass('ui-state-error ui-corner-all')
          .effect('highlight', {color: '#FFAAAA'}, 500);

        htmlDiv.find('form div.errors').fadeIn('fast');
      }
    });
  };

  _this.setTabindexes = function() {
    htmlDiv.find('form input,select').each(function(index) {
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
        htmlDiv.find('.error-compte').remove();

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

    htmlDiv.find('input[name=comment]').blur(function() {
      fieldset = htmlDiv.find('fieldset#assentaments');
      var nrows = _this.assentament.nrows(fieldset);

      if (nrows == 1) {
        fieldset.find('input.import')
          .val(htmlDiv.find('fieldset.main input[name=import]').val());
        fieldset.find('input.comment')
          .val(htmlDiv.find('fieldset.main input[name=comment]').val());
      }
    });

    htmlDiv.find('div.ctcte-combobox').bind('select', function() {
        _this.getCodiCompte(tCtekey.val());
    });

    htmlDiv.find('form').submit(function() {
      _this.submit();
      
      /* Cancel primary submit action (.preventDefault()) */
      return false;
    });
  };

  _this.fire = function() {
    htmlDiv.jqxExpander({ showArrow: false, toggleMode: 'none' });
    inputToNumeric(htmlDiv.find('fieldset.main div.numeric'),
                   htmlDiv.find('fieldset.main input.import'),
                   '230px',
                   htmlDiv.find('fieldset.main input.import').attr('height'));
    htmlDiv.find('div.numeric').find('input').attr({tabindex: '5',
                                               name: 'import'});

    _this.assentament = new Assentament(htmlDiv);

    _this.getComptes();
  };
  
}

function Assentament(parentHtmlDiv) {
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
